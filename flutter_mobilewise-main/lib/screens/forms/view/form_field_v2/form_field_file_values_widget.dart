import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/util.dart';
import '../../model/s3_file_model.dart';
import '../../view_model/form_view_model.dart';
import '../../../../utils/common_constants.dart' as constants;

class FormFieldFileValuesWidget extends StatefulWidget {
  const FormFieldFileValuesWidget({
    Key? key,
    required this.field,
    required this.viewModel,
    this.value,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;
  final String? value;


  @override
  State<FormFieldFileValuesWidget> createState() => _FormFieldFileValuesWidgetState();
}

class _FormFieldFileValuesWidgetState extends State<FormFieldFileValuesWidget> {
  List<dynamic> fileUrls = [];
  List<S3FileModel> s3Files = [];

  @override
  void initState() {
    super.initState();
    String value = widget.value ??
        widget.viewModel.dataListSelected?.dataMap?[widget.field.defaultValue]
            ?.value ??
        '';

    if (value.isNotEmpty) {
      if (Util.instance.isJSON(value)) {
        fileUrls = json.decode(value);
        for (String url in fileUrls) {
          s3Files.add(S3FileModel(url: url, isDownloading: false));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: _view(),
    );
  }

  _view() {
    return Padding(
      padding: const EdgeInsets.all(constants.mediumPadding),
      child: Column(
        children: [
          Align(
            alignment: widget.viewModel.getAlignment('left'),
            child: Text(
              '${widget.field.label}: ',
              style: constants.smallGreyTextStyle,
            ),
          ),
          Align(
            alignment: widget.viewModel.getAlignment('left'),
            child: Padding(
              padding: const EdgeInsets.only(top: constants.mediumPadding),
              child: s3Files.isEmpty
                  ? Text(
                constants.attachmentsNotAvailableMsg,
                style: constants.normalBlackTextStyle,
              )
                  : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: constants.formFieldHeight,
                child: _getFileThumbnails(),
              ),
            ),
          )
        ],
      )
    );
  }

  _getFileThumbnails() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: s3Files.length,
      itemBuilder: (BuildContext context, int index) {
        String? url = s3Files[index].url;
        if (url != null && url.isNotEmpty) {
          return InkWell(
            onTap: () async{
              await _downloadAndSaveFile(s3Files[index]);
            },
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, constants.smallPadding, 0.0),
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
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              Util.instance.getImageForMimeType(
                                  url.split(".").last),
                              height: constants.mimeTypeImageHeight,
                              width: constants.mimeTypeImageWidth,
                            ),
                            s3Files[index].isDownloading ? SizedBox(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: HexColor(AppState.instance.themeModel.primaryColor),
                                ),
                              ),
                            ) : const SizedBox(),
                          ],
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(constants.xSmallPadding, constants.xSmallPadding, 0.0, 0.0),
                            child: Tooltip(
                              message: s3Files[index].url!.split("/").last,
                              child: Text(
                                s3Files[index].url!.split("/").last,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                )
            )
          );
        }
        return const SizedBox();
      },
    );
  }

  _downloadAndSaveFile(S3FileModel s3File) async{
    final directory = await getApplicationDocumentsDirectory();
    String fileName = s3File.url!.split("/").last;

    String filePath = _checkIfFileExists(directory.path, fileName);

    if (filePath.isNotEmpty) {
      await OpenFilex.open(filePath);
      return;
    }

    setState(() {
      s3File.isDownloading = true;
    });

    Uint8List data = await Util.instance.downloadFile(s3File.url!);
    File newFile = await File('${directory.path}/$fileName').create();
    newFile.writeAsBytesSync(data);

    setState(() {
      s3File.isDownloading = false;
    });

    await OpenFilex.open(newFile.path);
  }

  _checkIfFileExists(String directoryPath, String fileName) {
    final directory = Directory(directoryPath);
    List<FileSystemEntity> files = [];
    files = directory.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity file in files) {
      if (file.path.split("/").last == fileName) {
        return file.path;
      }
    }
    return "";
  }

}
