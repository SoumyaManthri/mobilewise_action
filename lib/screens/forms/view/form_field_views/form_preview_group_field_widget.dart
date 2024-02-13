import 'package:flutter/material.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../utils/form_renderer_util.dart';
import '../../../../utils/common_constants.dart' as constants;

class FormPreviewGroupFieldWidget extends StatefulWidget {
  const FormPreviewGroupFieldWidget({
    Key? key,
    required this.form,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkForm form;
  final FormViewModel viewModel;

  @override
  State<FormPreviewGroupFieldWidget> createState() =>
      _FormPreviewGroupFieldWidgetState();
}

class _FormPreviewGroupFieldWidgetState
    extends State<FormPreviewGroupFieldWidget> {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    widgets.addAll(_getFormFields());
    return widgets.isNotEmpty ? Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, constants.mediumPadding),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: constants.dropdownContainerDecoration,
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: _getFormFields(),
        ),
      ),
    ) : const SizedBox();
  }

  _getFormFields() {
    List<Widget> fields = <Widget>[];
    List<FocusNode> focusList =[];
    for (FrameworkFormField field in widget.form.fields) {
      if(!field.isEditable && widget.viewModel.clickedSubmissionValuesMap
          .containsKey(field.key) && widget.viewModel.clickedSubmissionValuesMap
          [field.key].toString().isNotEmpty) {
        focusList.add(FocusNode());
        fields.add(FormRendererUtil.instance
            .getFormFieldWidget(field, widget.viewModel,focusList, formType: constants.previewFormType));
        fields.add(Padding(
          padding: const EdgeInsets.fromLTRB(constants.mediumPadding,
              0, constants.mediumPadding, 0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: constants.horizontalSeparatorHeight,
            color: const Color(constants.previewSeparatorColor),
          ),
        ));
      }
    }
    if (fields.isNotEmpty) {
      fields.removeAt(fields.length - 1);
    }
    return fields;
  }
}
