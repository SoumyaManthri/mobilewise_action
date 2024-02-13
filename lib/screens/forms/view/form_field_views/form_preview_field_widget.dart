import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../screens/forms/model/form_image_field_widget_media.dart';
import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/form_renderer_util.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';

class FormPreviewFieldWidget extends StatefulWidget {
  const FormPreviewFieldWidget({
    Key? key,
    required this.fieldKey,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final String fieldKey;
  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormPreviewFieldWidget> createState() => _FormPreviewFieldWidgetState();
}

class _FormPreviewFieldWidgetState extends State<FormPreviewFieldWidget> {
  String value = '';
  List<dynamic> images = [];
  List<dynamic> files = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.getScrollController().jumpTo(0.0);
    });
  }

  _initValue() {
    images.clear();
    files.clear();

    if (AppState.instance.formTempMap.containsKey(widget.fieldKey)) {
      if (widget.field.uiType == constants.image) {
        images.addAll(AppState.instance.formTempMap[widget.fieldKey]);
      }else if (widget.field.uiType == constants.filePicker) {
        files.addAll(AppState.instance.formTempMap[widget.fieldKey]);
      } else if (widget.field.uiType == constants.date) {
        value = Util.instance
            .getDisplayDate(AppState.instance.formTempMap[widget.fieldKey]);
      } else {
        value = AppState.instance.formTempMap[widget.fieldKey];
      }
    } else if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.fieldKey)) {
      if (widget.field.uiType == constants.image) {
        String hashSeparatedString =
            widget.viewModel.clickedSubmissionValuesMap[widget.field.key];
        List<String> imageNames = hashSeparatedString.split('#');
        for (String i in imageNames) {
          images.add(FormImageFieldWidgetMedia(
              false, i, null, '${constants.s3BucketBaseUrl}$i'));
        }
        images.addAll(
            widget.viewModel.clickedSubmissionValuesMap[widget.fieldKey]);
      }else if (widget.field.uiType == constants.filePicker) {
        String hashSeparatedString =
        widget.viewModel.clickedSubmissionValuesMap[widget.field.key];
        List<String> imageNames = hashSeparatedString.split('#');
        for (String i in imageNames) {
          files.add(FormImageFieldWidgetMedia(
              false, i, null, '${constants.s3BucketBaseUrl}$i'));
        }
        files.addAll(
            widget.viewModel.clickedSubmissionValuesMap[widget.fieldKey]);
      }  else if (widget.field.uiType == constants.date) {
        value = Util.instance.getDisplayDate(
            widget.viewModel.clickedSubmissionValuesMap[widget.fieldKey]);
      } else {
        value = widget.viewModel.clickedSubmissionValuesMap[widget.fieldKey];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initValue();
    if (value.isEmpty && images.isEmpty && files.isEmpty) {
      return const SizedBox();
    }
    switch (widget.field.uiType) {
      case constants.image:
        return Padding(
          padding: const EdgeInsets.only(bottom: constants.mediumPadding),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: constants.mediumPadding,
                vertical: constants.smallPadding),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.field.label,
                        style: constants.smallGreyTextStyle,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: constants.mediumPadding),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: constants.cameraPlaceholderImageHeight,
                          child: images.isEmpty
                              ? const Image(
                                  image: AssetImage(constants.defaultImage),
                                  fit: BoxFit.fill,
                                )
                              : _getImageThumbnails(),
                        ),
                      ),
                    ])),
          ),
        );
      case constants.filePicker:
        return Padding(
          padding: const EdgeInsets.only(bottom: constants.mediumPadding),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: constants.mediumPadding,
                vertical: constants.smallPadding),
            child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.field.label,
                        style: constants.smallGreyTextStyle,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: constants.mediumPadding),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: constants.formFieldHeight,
                          child: files.isEmpty
                              ? const Image(
                            image: AssetImage(constants.defaultImage),
                            fit: BoxFit.fill,
                          )
                              : _getFileThumbnails(),
                        ),
                      ),
                    ])),
          ),
        );
      case constants.geotag:
        List<String> latLng = [];
        if (value != null && value.isNotEmpty) {
          latLng = value.split(',');
        }
        return latLng.isNotEmpty
            ? Padding(
                  padding: const EdgeInsets.symmetric(vertical:constants.mediumPadding, horizontal:constants.mediumPadding),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.field.label,
                          style: constants.smallGreyTextStyle,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              0.0, constants.mediumPadding, 0.0, 0.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: constants.cameraPlaceholderImageHeight,
                            child: FlutterMap(
                              options: MapOptions(
                                center: LatLng(double.parse(latLng[0]),
                                    double.parse(latLng[1])),
                                zoom: 13,
                                maxZoom: 19,
                                interactiveFlags: InteractiveFlag.none,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: ['a', 'b', 'c'],
                                ),
                                MarkerLayer(markers: [
                                  Marker(
                                      point: LatLng(double.parse(latLng[0]),
                                          double.parse(latLng[1])),
                                      child: const Icon(
                                        Icons.location_on_rounded,
                                        color: Colors.red,
                                        size: constants.markerIconDimension,
                                      ))
                                ])
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            : const SizedBox();
      default:
        return FormRendererUtil.instance.getFormFieldWidget(
            widget.field, widget.viewModel, [],
            formType: constants.previewFormType, value: value);
    }
  }

  getTextLabel() {
    return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: constants.mediumPadding,
            vertical: constants.smallPadding),
        child: Align(
          alignment: Alignment.centerLeft,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              widget.field.label,
              style: constants.smallGreyTextStyle,
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(
                    0.0, constants.smallPadding, 0.0, constants.smallPadding),
                child: Text(
                  value,
                  style: constants.normalBlackTextStyle,
                ))
          ]),
        ));
  }

  _getImageThumbnails() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: images.length,
      itemBuilder: (BuildContext context, int index) {
        if (images[index].isLocal) {
          /// Image is a local image from current form session
          String? path = images[index].path;
          if (path != null && path.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(right: constants.mediumPadding),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  InkWell(
                    onTap: () {
                      NavigationUtil.instance.navigateToImagePreviewScreen(
                          context, path.toString(), null);
                    },
                    child: SizedBox(
                      height: constants.cameraPlaceholderImageHeight,
                      child: Image.file(
                        File(path),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        } else {
          /// Image is an online image submitted from an older session
          String? url = images[index].url;
          if (url != null && url.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(right: constants.mediumPadding),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  InkWell(
                    onTap: () {
                      NavigationUtil.instance
                          .navigateToImagePreviewScreen(context, null, url);
                    },
                    child: SizedBox(
                      height: constants.cameraPlaceholderImageHeight,
                      child: Image.network(url),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        }
      },
    );
  }

  _getFileThumbnails() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: files.length,
      itemBuilder: (BuildContext context, int index) {
          /// Image is a local image from current form session
          String? path = files[index].path;
          if (path != null && path.isNotEmpty) {
            return InkWell(
              onTap: () {
                _openFile(files[index]);
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
                          Image.asset(
                            Util.instance.getImageForMimeType(
                                files[index].name.split(".").last),
                            height: constants.mimeTypeImageHeight,
                            width: constants.mimeTypeImageWidth,
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(constants.xSmallPadding, constants.xSmallPadding, 0.0, 0.0),
                              child: Tooltip(
                                message: files[index].name.split(".").first,
                                child: Text(
                                  files[index].name.split(".").first,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                  )
              ),
            );
          }
      },
    );
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
