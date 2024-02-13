import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
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
  String? errorMessage;
  TextEditingController textEditingController = TextEditingController();
  FocusNode myfocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeFiles();
    widget.viewModel.filePickerFields[widget.field.key] = widget.field;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(
            0.0,
            Util.instance.getTopMargin(widget.field.style),
            0.0,
            constants.mediumPadding),
        child: _view());
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

  TextFormField textField() {
    refreshText();

    return TextFormField(
      readOnly: false,
      focusNode: myfocus,
      autovalidateMode: AutovalidateMode.always,
      showCursor: false,
      controller: textEditingController,
      keyboardType: TextInputType.none,
      enableInteractiveSelection: false,
      enableSuggestions: false,
      onTap: () {
        myfocus.unfocus();
        onTap();
      },
      autocorrect: false,
      decoration: borderOutlined(),
      validator: (value) {
        return validation();
      },
    );
  }

  InputDecoration borderOutlined() {
    return InputDecoration(
        label: constants.mandatoryField(widget.field),
        // labelText: widget.field.label,
        hintText: '${_files.length} file(s) selected',
        helperText: errorMessage,
        fillColor: HexColor(AppState.instance.themeModel.backgroundColor),
        filled: true,
        // floatingLabelBehavior: FloatingLabelBehavior.never,
        border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.red)),
        floatingLabelStyle: TextStyle(
            color: HexColor(AppState.instance.themeModel.primaryColor)),
        labelStyle: const TextStyle(color: Colors.black),
        errorStyle: const TextStyle(color: Colors.red),
        suffixIcon: const Icon(Icons.file_copy_outlined, color: Colors.black));
  }

  refreshText() {
    if (_files.isNotEmpty) {
      textEditingController.text = '${_files.length} file(s) selected';
    } else {
      textEditingController.text = '';
    }
  }

  validation() {
    if (widget.viewModel.errorWidgetMap.containsKey(widget.field.key)) {
      widget.viewModel.scrollToFirstValidationErrorWidget(context);
      errorMessage = widget.viewModel.errorWidgetMap[widget.field.key]!;
    }
    return null;
  }

  _view() {
    return Column(
      children: [
        textField(),
        const SizedBox(
          height: constants.smallPadding,
        ),
        _files.isNotEmpty
            ? SizedBox(
                width: MediaQuery.of(context).size.width,
                height: constants.fileThumbnailListHeight,
                child: _getFileThumbnails(),
              )
            : const SizedBox(),
      ],
    );
  }

  onTap() async {
    /// Checking for max limit on file capture
    if (widget.field.max != null &&
        widget.field.max! > 0 &&
        _files.length == widget.field.max!) {
      Util.instance.showSnackBar(context, constants.maxFileCaptureMessage);
      return;
    }

    /// Can attach more files
    /// 1. Open gallery for user to select files
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      await _createFile(result);
    } else {
      if (!mounted) return;
      Util.instance.showSnackBar(context, constants.fileCaptureErrorMessage);
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
    addFileToSubmissionMap();
  }

  addFileToSubmissionMap() {
    AppState.instance.addToFormTempMap(widget.field.key, _files);
  }

  removeFromSubmissionMap(FormImageFieldWidgetMedia file) {
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
        scrollDirection: Axis.horizontal,
        itemCount: _files.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              onTap: () {
                _openFile(_files[index]);
              },
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0.0, 0.0, constants.smallPadding, 0.0),
                  child: Container(
                      height: constants.fileThumbnailHeight,
                      width: constants.fileThumbnailWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFFdae3dc),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            Util.instance.getImageForMimeType(
                                _files[index].name.split(".")[1]),
                            height: constants.mimeTypeImageHeight,
                            width: constants.mimeTypeImageWidth,
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      constants.xSmallPadding, 0.0, 0.0, 0.0),
                                  child: Tooltip(
                                    message: _files[index].name,
                                    child: Text(
                                      _files[index].name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              widget.field.isEditable
                                  ? IconButton(
                                      onPressed: () {
                                        setState(() {
                                          removeFromSubmissionMap(
                                              _files.elementAt(index));
                                          _files.removeAt(index);
                                          refreshText();
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        size: constants.closeIconDimension,
                                        color: Colors.black,
                                      ))
                                  : const SizedBox()
                            ],
                          )
                        ],
                      ))));
        });
  }

  _getVerticalFileThumbnails() {
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
                                  removeFromSubmissionMap(
                                      _files.elementAt(index));
                                  _files.removeAt(index);
                                  refreshText();
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
