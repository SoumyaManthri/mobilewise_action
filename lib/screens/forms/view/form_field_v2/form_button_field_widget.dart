import 'package:flutter/material.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/hex_color.dart';
import '../../../../utils/util.dart';

class FormButtonFieldWidget extends StatefulWidget {
  const FormButtonFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormButtonFieldWidget> createState() => _FormButtonFieldWidgetState();
}

class _FormButtonFieldWidgetState extends State<FormButtonFieldWidget> {
  late Color bgColor;
  FrameworkFormStyle? style;

  @override
  Widget build(BuildContext context) {
    style = widget.field.style;
    if (widget.field.style != null && widget.field.style!.bgColor.isNotEmpty) {
      bgColor = HexColor(widget.field.style!.bgColor);
    } else {
      bgColor = HexColor(AppState.instance.themeModel.primaryColor);
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(
          0.0,
          Util.instance.getTopMargin(widget.field.style),
          0.0,
          constants.mediumPadding),
      child: SizedBox(
        height: constants.buttonHeight,
        width: MediaQuery.of(context).size.width,
        child: FilledButton(
          onPressed: () async {
            widget.viewModel.fieldButtonPressed(
                widget.field, context, true, widget.field.label);
          },
          style: constants.buttonStyle(backgroundColor: bgColor),
          child: Text(
            widget.field.valuesApi.isPreview ? 'Preview' : widget.field.label,
            style: constants.applyStyleV2(
                bold: style!.bold,
                underline: style!.underline,
                italics: style!.italics,
                color: style!.color,
                size: style!.size),
          ),
        ),
      ),
    );
  }
}
