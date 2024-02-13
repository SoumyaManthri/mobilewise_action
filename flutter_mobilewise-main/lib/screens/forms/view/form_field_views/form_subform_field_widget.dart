import 'package:flutter/material.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/form_renderer_util.dart';

class FormSubformFieldWidget extends StatefulWidget {
  const FormSubformFieldWidget({
    Key? key,
    required this.form,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkForm form;
  final FormViewModel viewModel;

  @override
  State<FormSubformFieldWidget> createState() => _FormSubformFieldWidgetState();
}

class _FormSubformFieldWidgetState extends State<FormSubformFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: _getFormFields(),
    );
  }

  _getFormFields() {
    List<Widget> fields = <Widget>[];
    List<FocusNode> focusList =[];
    for (FrameworkFormField field in widget.form.fields) {
      focusList.add(FocusNode());
      fields.add(FormRendererUtil.instance
          .getFormFieldWidget(field, widget.viewModel,focusList));
      AppState.instance
          .addToFormTempWidgetMap(field.key, field, widget.form.entityKey);}
    if (fields.isEmpty) {
      fields.add(const SizedBox());
    }
    return fields;
  }
}
