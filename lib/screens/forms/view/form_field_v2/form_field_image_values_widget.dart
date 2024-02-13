import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../../view_model/form_view_model.dart';
import '../../../../utils/common_constants.dart' as constants;

class FormFieldImageValuesWidget extends StatefulWidget {
  const FormFieldImageValuesWidget({
    Key? key,
    required this.field,
    required this.viewModel,
    this.value,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;
  final String? value;

  @override
  State<FormFieldImageValuesWidget> createState() => _FormFieldImageValuesWidgetState();
}

class _FormFieldImageValuesWidgetState extends State<FormFieldImageValuesWidget> {
  List<dynamic> imageUrls = [];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: _view(),
    );
  }

  _view() {
    String value = widget.value ??
        widget.viewModel.dataListSelected?.dataMap?[widget.field.defaultValue]
            ?.value ??
        '';

    if (value.isNotEmpty) {
      if (Util.instance.isJSON(value)) {
        imageUrls = json.decode(value);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(constants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              padding:
              const EdgeInsets.only(top: constants.mediumPadding),
              child: imageUrls.isEmpty
                  ? Text(
                constants.attachmentsNotAvailableMsg,
                style: constants.normalBlackTextStyle,
              )
                  : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: constants.cameraPlaceholderImageHeight,
                child: _getImageThumbnails(),
              ),
            ),
          )
        ],
      )
    );
  }

  _getImageThumbnails() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: imageUrls.length,
      itemBuilder: (BuildContext context, int index) {
        String? url = imageUrls[index];
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
                    child: Image.network(
                      url,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                              color: HexColor(AppState.instance.themeModel.primaryColor),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            backgroundColor: const Color(constants.greySeparatorColor)
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

}
