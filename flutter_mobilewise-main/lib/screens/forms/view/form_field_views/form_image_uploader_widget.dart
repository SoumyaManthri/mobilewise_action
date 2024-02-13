import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/util.dart';

class FormImageUploaderWidget extends StatefulWidget {
  const FormImageUploaderWidget({
    Key? key,
    required this.field,
    required this.fieldKey,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final String fieldKey;
  final FormViewModel viewModel;

  @override
  State<FormImageUploaderWidget> createState() =>
      _FormImageUploaderWidgetState();
}

class _FormImageUploaderWidgetState extends State<FormImageUploaderWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.field.image.isNotEmpty
        ? Padding(
            padding: EdgeInsets.fromLTRB(
                constants.mediumPadding,
                Util.instance.getTopMargin(widget.field.style),
                constants.mediumPadding,
                constants.smallPadding),
            child: GestureDetector(
                onTap: _onPressed,
                child: Image.memory(
                  base64Decode(widget.field.image),
                  fit: BoxFit.cover,
                )),
          )
        : const SizedBox();
  }

  _onPressed() {
    widget.viewModel.fieldButtonPressed(widget.field, context, false, '');
  }
}
