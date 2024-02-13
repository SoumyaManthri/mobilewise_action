import 'package:flutter/material.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/form_renderer_util.dart';

class FormColumnFieldWidget extends StatefulWidget {
  const FormColumnFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormColumnFieldWidget> createState() => _FormColumnFieldWidgetState();
}

class _FormColumnFieldWidgetState extends State<FormColumnFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment:
          widget.field.orientation == constants.columnOrientationRight
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: _renderColumnChildren(widget.field.subform),
    );
  }

  _renderColumnChildren(String subformKey) {
    FrameworkForm subform = widget.viewModel.findFormByKey(subformKey);
    List<Widget> fields = <Widget>[];
    List<FocusNode> focusList =[];
    for (FrameworkFormField field in subform.fields) {
      focusList.add(FocusNode());
      fields.add(FormRendererUtil.instance
          .getFormFieldWidget(field, widget.viewModel, focusList));
    }
    if (fields.isEmpty) {
      fields.add(const SizedBox());
    }
    return fields;
  }
}
