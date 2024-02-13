import 'package:flutter/material.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/common_constants.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/util.dart';

class FormTextFieldWidget extends StatefulWidget {
  const FormTextFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormTextFieldWidget> createState() => _FormTextFieldWidgetState();
}

class _FormTextFieldWidgetState extends State<FormTextFieldWidget> {
  late String? value;

  @override
  Widget build(BuildContext context) {
    value = _initValue();
    if (value == null || value!.isEmpty) {
      return const SizedBox();
    }
    double textSize = widget.field.textSize.toDouble();
    String style = widget.field.textStyle;
    Map<String, dynamic> colorMap = widget.field.textColor;

    /// Initializing the text color
    late Color color;
    if (colorMap.containsKey(value)) {
      color = Color(int.parse('FF${colorMap[value]}', radix: 16));
    } else if (colorMap.containsKey(constants.defaultKey)) {
      color =
          Color(int.parse('FF${colorMap[constants.defaultKey]}', radix: 16));
    } else {
      color = Colors.black;
    }

    /// Initializing the text style
    TextStyle s = style == constants.bold
        ? TextStyle(
            fontSize: textSize,
            color: color,
            fontWeight: FontWeight.w500,
          )
        : TextStyle(
            fontSize: textSize,
            color: color,
          );
    return widget.field.icon.isNotEmpty
        ? InkWell(
            onTap: () {
              if (widget.field.decisionNode != null) {
                _onPressed();
              }
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  0.0,
                  Util.instance.getTopMargin(widget.field.style),
                  0.0,
                  constants.smallPadding),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        0.0, 0.0, constants.smallPadding, 0.0),
                    child: SizedBox(
                      width: constants.closeIconDimension,
                      height: constants.closeIconDimension,
                      child: Image(
                        image: AssetImage(widget.field.icon),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Align(
                      alignment: getAlignment(), child: Text(value!, style: s)),
                ],
              ),
            ),
          )
          : GestureDetector(
            onTap: () {
              _onPressed();
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  0.0,
                  Util.instance.getTopMargin(widget.field.style),
                  0.0,
                  constants.smallPadding),
              child: Align(
                alignment: getAlignment(),
                child: mandatoryField(widget.field),
              ),
            ),
          );
  }

  _onPressed() {
    widget.viewModel.fieldButtonPressed(widget.field, context, false, '');
  }

  AlignmentGeometry getAlignment() {
    switch (widget.field.style?.textAlign?.toLowerCase()) {
      case 'right':
        return Alignment.centerRight;
      case 'center':
        return Alignment.center;
      case 'left':
      default:
        return Alignment.centerLeft;
    }
  }

  /// Initializing the value of the widget
  _initValue() {
    if (AppState.instance.formTempMap.containsKey(widget.key)) {
      value = AppState.instance.formTempMap[widget.key];
    } else if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.key)) {
      value = widget.viewModel.clickedSubmissionValuesMap[widget.key];
    } else {
      value = widget.field.label;
    }

    return value;
  }
}
