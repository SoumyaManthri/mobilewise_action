import 'package:flutter/material.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../../utils/common_constants.dart' as constants;
import '../../../../../utils/form_renderer_util.dart';

class FormRowFieldWidget extends StatefulWidget {
  const FormRowFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormRowFieldWidget> createState() => _FormColumnFieldWidgetState();
}

class _FormColumnFieldWidgetState extends State<FormRowFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: _renderRowChildren(widget.field.subform),
    );
  }

  _renderRowChildren(String subformKey) {
    FrameworkForm subform = widget.viewModel.findFormByKey(subformKey);
    List<Widget> fields = <Widget>[];
    List<FocusNode> focusList =[];
    for (FrameworkFormField field in subform.fields) {
      focusList.add(FocusNode());
      fields.add(Expanded(
        flex: field.flex,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            0.0,
            0.0,
            constants.smallPadding,
            0.0,
          ),
          child: FormRendererUtil.instance
              .getFormFieldWidget(field, widget.viewModel,focusList),
        ),
      ));
    }
    if (fields.isEmpty) {
      fields.add(const SizedBox());
    }
    return fields;
  }
}
