import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/utils/hex_color.dart';

import '../../../../screens/forms/view/form_field_views/form_subform_field_widget.dart';
import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/util.dart';

/// Single select checkbox widget
/// If the selected value is linked to a sub-form through a decision node, then
/// on selection, the form is rendered below the checkbox
class FormSingleSelectCheckboxFieldWidget extends StatefulWidget {
  const FormSingleSelectCheckboxFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormSingleSelectCheckboxFieldWidget> createState() =>
      _FormSingleSelectCheckboxFieldWidgetState();
}

class _FormSingleSelectCheckboxFieldWidgetState
    extends State<FormSingleSelectCheckboxFieldWidget> {
  String selectedValue = '';
  FrameworkForm form = FormViewModel.emptyFormData();

  @override
  void initState() {
    super.initState();

    /// Checking if value already exists
    if (widget.field.isEditable &&
        AppState.instance.formTempMap.containsKey(widget.field.key)) {
      selectedValue = AppState.instance.formTempMap[widget.field.key];
    } else if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.field.key)) {
      selectedValue =
          widget.viewModel.clickedSubmissionValuesMap[widget.field.key];
    }

    if (selectedValue.isNotEmpty) {
      /// Checking for a subform for the selected value
      for (FrameworkFormFieldValue value in widget.field.values) {
        if (selectedValue == value.value) {
          if (value.decisionNode.conditions.containsKey(constants.defaultKey)) {
            form = widget.viewModel.findFormByKey(value.decisionNode
                .conditions[constants.defaultKey][constants.subform]);
          }
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          0.0,
          Util.instance.getTopMargin(widget.field.style),
          0.0,
          constants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getCheckbox(),
      ),
    );
  }

  _getCheckboxChildren() {
    List<Widget> widgets = <Widget>[];
    if (widget.field.isEditable) {
      /// Checkbox is editable
      for (FrameworkFormFieldValue value in widget.field.values) {
        widgets.add(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  0.0, 0.0, constants.mediumPadding, 0.0),
              child: Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: value.value == selectedValue ? true : false,
                fillColor: value.value == selectedValue
                    ? MaterialStateProperty.all<Color>(Colors.black)
                    : MaterialStateProperty.all<Color>(
                        HexColor(AppState.instance.themeModel.primaryColor)),
                checkColor: HexColor(AppState.instance.themeModel.primaryColor),
                onChanged: (isSelected) {
                  setState(() {
                    /// Checking if the value is linked to a decision node and
                    /// contains a sub-form
                    if (value.decisionNode.conditions
                        .containsKey(constants.defaultKey)) {
                      form = widget.viewModel.findFormByKey(value.decisionNode
                          .conditions[constants.defaultKey][constants.subform]);
                    } else {
                      /// Initializing an empty form so that no sub-form is rendered
                      form = FormViewModel.emptyFormData();
                    }
                    selectedValue = value.value;
                    AppState.instance
                        .addToFormTempMap(widget.field.key, selectedValue);
                  });
                },
              ),
            ),
            Expanded(
              child: Text(
                value.value,
                style: constants.normalBlackTextStyle,
                maxLines: 3,
              ),
            ),
          ],
        ));
      }
    } else {
      /// Checkbox is non-editable
      widgets.add(selectedValue.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(constants.mediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.field.label,
                    style: constants.smallGreyTextStyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        0.0, constants.mediumPadding, 0.0, 0.0),
                    child: Text(
                      selectedValue,
                      style: constants.normalBlackTextStyle,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox());
    }

    /// Checking if sub-form needs to be added to this widget layout
    if (form.formKey.isNotEmpty && form.fields.isNotEmpty) {
      /// Adding subform to widget
      widgets.add(Padding(
        padding:
            const EdgeInsets.fromLTRB(0.0, constants.smallPadding, 0.0, 0.0),
        child: FormSubformFieldWidget(
          form: form,
          viewModel: widget.viewModel,
        ),
      ));
    }

    /// Adding SizedBox to avoid error is no values exist for the checkbox
    if (widgets.isEmpty) {
      widgets.add(const SizedBox());
    }
    return widgets;
  }

  _getCheckbox() {
    List<Widget> widgets = [];
    FrameworkFormFieldValue? formFieldValue;
    if (widget.field.values.isNotEmpty) {
      formFieldValue = widget.field.values[0];
    }

    widgets.add(Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.fromLTRB(0.0, 0.0, constants.mediumPadding, 0.0),
          child: Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: selectedValue.isNotEmpty ? bool.parse(selectedValue) : false,
            onChanged: (isSelected) {
              setState(() {
                /// Checking if the value is linked to a decision node and
                /// contains a sub-form
                if (formFieldValue?.decisionNode.conditions
                        .containsKey(constants.defaultKey) ==
                    true) {
                  form = widget.viewModel.findFormByKey(formFieldValue
                      ?.decisionNode
                      .conditions[constants.defaultKey][constants.subform]);
                } else {
                  /// Initializing an empty form so that no sub-form is rendered
                  form = FormViewModel.emptyFormData();
                }
                if (formFieldValue != null) {
                  selectedValue = formFieldValue.value ?? "";
                } else {
                  selectedValue = "$isSelected";
                }
                AppState.instance
                    .addToFormTempMap(widget.field.key, selectedValue);
              });
            },
          ),
        ),
        Expanded(
          child: Text(
            widget.field.label,
            style: constants.normalBlackTextStyle,
            maxLines: 3,
          ),
        ),
      ],
    ));
    return widgets;
  }
}
