import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../screens/forms/model/form_image_field_widget_media.dart';
import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/hex_color.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';

class FormImageFieldWidget extends StatefulWidget {
  const FormImageFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormImageFieldWidget> createState() => _FormImageFieldWidgetState();
}

class _FormImageFieldWidgetState extends State<FormImageFieldWidget> {
  TextEditingController textEditingController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<dynamic> _images = [];
  String? errorMessage;
  FocusNode myfocus = FocusNode();

  @override
  void initState() {
    /// Initialize images
    _initializeImages();
    widget.viewModel.imageFields[widget.field.key] = widget.field;
    super.initState();
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
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: _view(),
            ),
          )
        : _view();
  }

  _initializeImages() {
    _images.clear();
    if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.field.key)) {
      String hashSeparatedString =
          widget.viewModel.clickedSubmissionValuesMap[widget.field.key];
      List<String> imageNames = hashSeparatedString.split('#');
      for (String i in imageNames) {
        _images.add(FormImageFieldWidgetMedia(
            false, i, null, '${constants.s3BucketBaseUrl}$i'));
      }
    } else if (AppState.instance.formTempMap.containsKey(widget.field.key)) {
      _images.addAll(AppState.instance.formTempMap[widget.field.key]);
    }

    /// Initializing images to formTempMap
    AppState.instance.formTempMap[widget.field.key] = [];
    AppState.instance.formTempMap[widget.field.key].addAll(_images);
  }

  _view() {
    return Column(
      children: [
        textField(),
        const SizedBox(
          height: constants.smallPadding,
        ),
        _images.isNotEmpty
            ? SizedBox(
                width: MediaQuery.of(context).size.width,
                height: constants.cameraPlaceholderImageHeight,
                child:
                    _images.isEmpty ? const SizedBox() : _getImageThumbnails(),
              )
            : const SizedBox(),
      ],
    );
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
        hintText: '${_images.length} image(s) selected',
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
        suffixIcon: const Icon(Icons.camera_alt_outlined, color: Colors.black));
  }

  onTap() async {
    /// Checking for max limit on image capture
    if (widget.field.max != null &&
        widget.field.max! > 0 &&
        _images.length == widget.field.max!) {
      /// Limit reached, cannot capture any more images
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.maxImageCaptureMessage),
      ));
    } else {
      /// Can capture more images
      /// 1. Open dialog to let the user choose between camera/gallery
      /// 2. Based on user choice either open camera, OR open gallery
      /// for the user to upload
      int value = await imageBottomsheet();

      if (value == 1 || value == 2) {
        XFile? photo;
        if (value == 1) {
          photo = await _picker.pickImage(source: ImageSource.camera);
        } else {
          photo = await _picker.pickImage(source: ImageSource.gallery);
        }

        if (photo != null) {
          /// after successful image capture remove the error field from the map
          widget.viewModel.errorWidgetMap.remove(widget.field.key);

          /// Reading XFile image as Uint8List
          Uint8List data = await photo.readAsBytes();
          final directory = await getApplicationDocumentsDirectory();

          /// Creating File using Uint8List
          /// Name of file is [userId_currentTimeInMs]
          String basename = '${const Uuid().v1()}.png';
          File file = await File('${directory.path}/$basename').create();
          file.writeAsBytesSync(data);

          /// Setting state so that thumbnails of captured images can be shown
          setState(() {
            _images.add(
                FormImageFieldWidgetMedia(true, basename, file.path, null));
          });
          _addImageToSubmissionMap();
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(constants.imageCaptureErrorMessage),
          ));
        }
      }
    }
  }

  refreshText() {
    if (_images.isNotEmpty) {
      textEditingController.text = '${_images.length} image(s) selected';
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

  _addImageToSubmissionMap() {
    AppState.instance.addToFormTempMap(widget.field.key, _images);
  }

  _removeFromSubmissionMap(FormImageFieldWidgetMedia image) {
    List<dynamic> existingImages = [];
    existingImages.addAll(AppState.instance.formTempMap[widget.field.key]);
    if (existingImages.isNotEmpty) {
      existingImages.remove(image);
      AppState.instance.addToFormTempMap(widget.field.key, existingImages);
      if (image.isLocal) {
        /// Deleting the file
        File file = File(image.path!);
        file.delete();
      }
    }
  }

  _getImageThumbnails() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _images.length,
      itemBuilder: (BuildContext context, int index) {
        if (_images[index].isLocal) {
          /// Image is a local image from current form session
          String? path = _images[index].path;
          if (path != null && path.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                constants.mediumPadding,
                0.0,
              ),
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
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          Util.instance.logMessage('Image Field Widget',
                              'Image.file failed -- $exception');
                          return Container(
                            height: constants.cameraPlaceholderImageHeight,
                            width: constants.networkImageErrorPlaceholderWidth,
                            decoration:
                                constants.networkImageContainerDecoration,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color:
                                    Color(constants.formFieldBackgroundColor),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  widget.field.isEditable
                      ? InkWell(
                          onTap: () {
                            setState(() {
                              _removeFromSubmissionMap(
                                  _images.elementAt(index));
                              _images.removeAt(index);
                              refreshText();
                            });
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.all(constants.smallPadding),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(constants.xSmallPadding),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: constants.closeIconDimension,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        } else {
          /// Image is an online image submitted from an older session
          String? url = _images[index].url;
          if (url != null && url.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                constants.mediumPadding,
                0.0,
              ),
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
                      child: Image.network(
                        url,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: constants.cameraPlaceholderImageHeight,
                            width: constants.networkImageErrorPlaceholderWidth,
                            decoration:
                                constants.networkImageContainerDecoration,
                            child: Center(
                              child: constants.blackIndicator,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          Util.instance.logMessage('Image Field Widget',
                              'Image.network failed -- $exception');
                          return Container(
                            height: constants.cameraPlaceholderImageHeight,
                            width: constants.networkImageErrorPlaceholderWidth,
                            decoration:
                                constants.networkImageContainerDecoration,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color:
                                    Color(constants.formFieldBackgroundColor),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  widget.field.isEditable
                      ? InkWell(
                          onTap: () {
                            setState(() {
                              _removeFromSubmissionMap(
                                  _images.elementAt(index));
                              _images.removeAt(index);
                              refreshText();
                            });
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.all(constants.smallPadding),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(constants.xSmallPadding),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: constants.closeIconDimension,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
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

  Future<int> imageBottomsheet() async {
    int value = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text(constants.imageDialogCamera),
                onTap: () {
                  Navigator.pop(context, 1);
                }),
            ListTile(
                leading: const Icon(Icons.photo),
                title: const Text(constants.imageDialogGallery),
                onTap: () {
                  Navigator.pop(context, 2);
                })
          ],
        );
      },
    );

    return value;
  }
}
