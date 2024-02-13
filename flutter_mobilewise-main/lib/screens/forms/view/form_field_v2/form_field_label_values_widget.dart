import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/common_constants.dart' as constants;

class FormLabelValueFieldWidget extends StatefulWidget {
  const FormLabelValueFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
    this.value,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;
  final String? value;

  @override
  State<FormLabelValueFieldWidget> createState() => _FormTextFieldWidgetState();
}

class _FormTextFieldWidgetState extends State<FormLabelValueFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: _view(),
    );
  }

  AlignmentGeometry getAlignment(String alignment) {
    switch (alignment.toLowerCase()) {
      case 'right':
        return Alignment.centerRight;
      case 'center':
        return Alignment.center;
      case 'left':
      default:
        return Alignment.centerLeft;
    }
  }

  _view() {
    String value = widget.value ??
        widget.viewModel.dataListSelected?.dataMap?[widget.field.defaultValue]
            ?.value ??
        '';
    if (widget.field.image == 'date_picker' && value.isNotEmpty) {
      try {
        DateFormat format = DateFormat("dd-MM-yyyy");
        DateTime dateTime = DateTime.parse(value);
        value = format.format(dateTime);
      } catch (e) {
        value = widget.value ?? '';
      }
    }

    return Padding(
      padding: const EdgeInsets.all(constants.mediumPadding),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: Align(
                alignment: getAlignment('left'),
                child: Text('${widget.field.label}: ',
                    style: constants.smallGreyTextStyle))),
        Expanded(
            child: Align(
                alignment: getAlignment('left'),
                child: Text(
                  value,
                  style: constants.normalBlackTextStyle,
                )))
      ]),
    );
  }
}
