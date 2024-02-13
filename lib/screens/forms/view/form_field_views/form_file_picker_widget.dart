import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/common_constants.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/util.dart';
import '../../model/form_image_field_widget_media.dart';
import '../../view_model/form_view_model.dart';

class FormFilePickerWidget extends StatefulWidget {
  const FormFilePickerWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormFilePickerWidget> createState() => _FormFilePickerWidgetState();
}

class _FormFilePickerWidgetState extends State<FormFilePickerWidget> {
  List<dynamic> _files = [];

  @override
  void initState() {
    super.initState();
    _initializeFiles();
    widget.viewModel.filePickerFields[widget.field.key] = widget.field;
  }

  @override
  Widget build(BuildContext context) {
    return widget.field.isEditable
        ? Padding(
            padding: EdgeInsets.fromLTRB(
                0.0,
                Util.instance.getTopMargin(widget.field.style),
                0.0,
                constants.mediumPadding),
            child: Material(
                elevation: constants.formComponentsElevation,
                borderRadius: constants.materialBorderRadius,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: constants.dropdownContainerDecoration,
                  child: Padding(
                    padding: const EdgeInsets.all(constants.mediumPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: widget.field.label,
                            style: applyStyle(widget.field.style),
                            children: <TextSpan>[
                              // Red * to show if the field is mandatory
                              TextSpan(
                                text: widget.field.isMandatory ? ' *' : '',
                                style: constants.normalRedTextStyle,
                              ),
                            ],
                          ),
                        ),
                        _view()
                      ],
                    ),
                  ),
                )))
        : _view();
  }

  _initializeFiles() {
    _files.clear();
    if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.field.key)) {
      String hashSeparatedString =
          widget.viewModel.clickedSubmissionValuesMap[widget.field.key];
      List<String> fileNames = hashSeparatedString.split("#");
      for (String f in fileNames) {
        _files.add(FormImageFieldWidgetMedia(
            false, f, null, '${constants.s3BucketBaseUrl}$f'));
      }
    } else if (AppState.instance.formTempMap.containsKey(widget.field.key)) {
      _files.addAll(AppState.instance.formTempMap[widget.field.key]);
    }

    /// Initializing files to formTempMap
    AppState.instance.formTempMap[widget.field.key] = [];
    AppState.instance.formTempMap[widget.field.key].addAll(_files);
  }

  _view() {
    return Padding(
      padding: widget.field.isEditable
          ? const EdgeInsets.all(constants.smallPadding)
          : const EdgeInsets.fromLTRB(
              constants.mediumPadding,
              constants.smallPadding,
              constants.mediumPadding,
              constants.smallPadding),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    /// Checking for max limit on file capture
                    if (widget.field.max != null &&
                        widget.field.max! > 0 &&
                        _files.length == widget.field.max!) {
                      Util.instance.showSnackBar(
                          context, constants.maxFileCaptureMessage);
                      return;
                    }

                    /// Can attach more files
                    /// 1. Open gallery for user to select files
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();
                    if (result != null) {
                      await _createFile(result);
                      _addFileToSubmissionMap();
                    } else {
                      if (!mounted) return;
                      Util.instance.showSnackBar(
                          context, constants.fileCaptureErrorMessage);
                    }
                  },
                  child: const Text("Browse..."),
                ),
              ),
              Expanded(
                child: Text(
                  _files.isEmpty
                      ? "No file selected"
                      : "${_files.length} files selected",
                ),
              ),
            ],
          ),
          const SizedBox(height: constants.smallPadding),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: _getThumbnailPlaceholderHeight(),
            child: _getFileThumbnails(),
          ),
          widget.field.isEditable
              ? const SizedBox()
              : const SizedBox(height: constants.mediumPadding),

          /// Show validation error on field if any
          validationErrorWidget(),
        ],
      ),
    );
  }

  validationErrorWidget() {
    if (widget.viewModel.errorWidgetMap.containsKey(widget.field.key)) {
      widget.viewModel.scrollToFirstValidationErrorWidget(context);
      return Text(
        widget.viewModel.errorWidgetMap[widget.field.key]!,
        style: constants.smallRedTextStyle,
      );
    } else {
      return const SizedBox();
    }
  }

  /// Create file selected from FilePicker
  _createFile(FilePickerResult result) async {
    File file = File(result.files.single.path!);
    String mimeType = file.path.split(".").last;

    /// after successful file upload remove the error field from the map
    widget.viewModel.errorWidgetMap.remove(widget.field.key);

    /// Reading XFile image as Uint8List
    Uint8List data = await file.readAsBytes();
    final directory = await getApplicationDocumentsDirectory();

    /// Creating File using Uint8List
    /// Name of file is [Time based V1 UUID]
    String basename = '${const Uuid().v1()}.$mimeType';
    File newFile = await File('${directory.path}/$basename').create();
    newFile.writeAsBytesSync(data);

    /// Setting state so that thumbnails of uploaded files can be shown
    setState(() {
      _files.add(FormImageFieldWidgetMedia(true, basename, newFile.path, null));
    });
  }

  _addFileToSubmissionMap() {
    AppState.instance.addToFormTempMap(widget.field.key, _files);
  }

  _removeFromSubmissionMap(FormImageFieldWidgetMedia file) {
    List<dynamic> existingFiles = [];
    existingFiles.addAll(AppState.instance.formTempMap[widget.field.key]);
    if (existingFiles.isNotEmpty) {
      existingFiles.remove(file);
      AppState.instance.addToFormTempMap(widget.field.key, existingFiles);
      if (file.isLocal) {
        File tempFile = File(file.path!);
        tempFile.delete();
      }
    }
  }

  _getFileThumbnails() {
    return ListView.builder(
        itemCount: _files.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              _openFile(_files[index]);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  0.0, 0.0, 0.0, constants.smallPadding),
              child: Container(
                  height: 40,
                  width: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFdae3dc),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        Util.instance.getImageForMimeType(
                            _files[index].name.split(".")[1]),
                        height: 22,
                        width: 22,
                      ),
                      Flexible(
                        child: Tooltip(
                          message: _files[index].name,
                          child: Text(_files[index].name,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      widget.field.isEditable
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  _removeFromSubmissionMap(
                                      _files.elementAt(index));
                                  _files.removeAt(index);
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                size: constants.closeIconDimension,
                                color: Colors.black,
                              ))
                          : const SizedBox(),
                    ],
                  )),
            ),
          );
        });
  }

  _getThumbnailPlaceholderHeight() {
    if (_files.isEmpty) {
      return 0.0;
    }
    if (_files.length >= 5) {
      return constants.maxFileThumbnailHeight;
    }
    return _files.length * constants.minFileThumbnailHeight;
  }

  _openFile(FormImageFieldWidgetMedia file) {
    if (file.isLocal) {
      /// We have the path for this file
      OpenFilex.open(file.path!);
    } else {
      /// Online file
      /// 1. Download the file from S3
      /// 2. Create a temporary file
      /// 3. Open the file
    }
  }
}
