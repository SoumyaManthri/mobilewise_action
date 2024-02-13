import 'package:flutter/material.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/util.dart';

class FormSeparatorFieldWidget extends StatefulWidget {
  const FormSeparatorFieldWidget({
    Key? key,
    required this.field,
  }) : super(key: key);

  final FrameworkFormField field;

  @override
  State<FormSeparatorFieldWidget> createState() =>
      _FormSeparatorFieldWidgetState();
}

class _FormSeparatorFieldWidgetState extends State<FormSeparatorFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        0.0,
        Util.instance.getTopMargin(widget.field.style),
        0.0,
        constants.smallPadding,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: constants.horizontalSeparatorHeight,
        color: Colors.black,
      ),
    );
  }
}
