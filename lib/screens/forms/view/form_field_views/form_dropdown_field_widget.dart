import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../screens/forms/view/form_field_views/form_subform_field_widget.dart';
import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/common_constants.dart';
import '../../../../utils/custom_drop_down.dart';
import '../../../../utils/util.dart';

class FormDropdownFieldWidget extends StatefulWidget {
  const FormDropdownFieldWidget(
      {Key? key,
      required this.field,
      required this.fieldKey,
      required this.viewModel,
      required this.position,
      required this.focusList})
      : super(key: key);

  final FrameworkFormField field;
  final String fieldKey;
  final FormViewModel viewModel;
  final int position;
  final List<FocusNode> focusList;

  @override
  State<FormDropdownFieldWidget> createState() =>
      _FormDropdownFieldWidgetState();
}

class _FormDropdownFieldWidgetState extends State<FormDropdownFieldWidget> {
  List<String> _selectedValue = [];
  final TextEditingController _textEditingController = TextEditingController();

  FrameworkForm subform = FormViewModel.emptyFormData();

  @override
  void initState() {
    widget.viewModel.dropdownNotLoadedCompletely.add(widget.fieldKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.createStringListForDropdown(
          widget.field, widget.fieldKey, context, true);
      if (_selectedValue != null &&
          _textEditingController.text != _selectedValue.join(', ')) {
        _textEditingController.text = _selectedValue!.join(', ');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormViewModel>(
      builder: (_, model, child) {
        List<String>? dropdownValues = model.dropdownValues[widget.fieldKey];
        if (dropdownValues != null && dropdownValues.isNotEmpty) {
          _initValue();
        }
        return widget.field.isEditable
            ? Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        0.0,
                        Util.instance.getTopMargin(widget.field.style),
                        0.0,
                        constants.mediumPadding),
                    child: Material(
                      elevation: constants.formComponentsElevation,
                      borderRadius: constants.materialBorderRadius,
                      child: Container(
                        decoration: constants.dropdownContainerDecoration,
                        child: Padding(
                          padding:
                              const EdgeInsets.all(constants.mediumPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: widget.field.label,
                                  style: applyStyle(widget.field.style),
                                  children: <TextSpan>[
                                    // Red * to show if the field is mandatory
                                    TextSpan(
                                      text:
                                          widget.field.isMandatory ? ' *' : '',
                                      style: constants.normalRedTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                              CustomDropDown(
                                  dropdownValues,
                                  _textEditingController,
                                  _selectedValue,
                                  widget.fieldKey,
                                  widget.field,
                                  widget.viewModel,
                                  widget.position,
                                  widget.focusList),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  subform.formKey.isNotEmpty
                      ? FormSubformFieldWidget(
                          form: subform,
                          viewModel: widget.viewModel,
                        )
                      : const SizedBox(),
                ],
              )
            : _selectedValue != null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                        constants.mediumPadding,
                        constants.smallPadding,
                        constants.mediumPadding,
                        constants.smallPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.field.label,
                          style: constants.smallGreyTextStyle,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              0.0,
                              constants.smallPadding,
                              0.0,
                              constants.smallPadding),
                          child: Text(
                            _selectedValue.toString(),
                            style: constants.normalBlackTextStyle,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox();
      },
    );
  }

  _initValue() {
    if (widget.field.isEditable &&
        AppState.instance.formTempMap.containsKey(widget.fieldKey) &&
        AppState.instance.formTempMap[widget.fieldKey].isNotEmpty) {
      _selectedValue = [AppState.instance.formTempMap[widget.fieldKey]];
    } else if (widget.viewModel.clickedSubmissionValuesMap
            .containsKey(widget.fieldKey) &&
        widget
            .viewModel.clickedSubmissionValuesMap[widget.fieldKey].isNotEmpty) {
      _selectedValue =
          widget.viewModel.clickedSubmissionValuesMap[widget.fieldKey];
      widget.viewModel.dropdownNotLoadedCompletely.remove(widget.fieldKey);
    } else {
      _selectedValue.clear();
    }

    subform = FormViewModel.emptyFormData();

    if (_selectedValue != null && _selectedValue!.isNotEmpty) {
      /// Checking for a subform for the selected value
      if (widget.field.values.isNotEmpty) {
        for (FrameworkFormFieldValue value in widget.field.values) {
          if (_selectedValue == value.value) {
            if (value.decisionNode.conditions
                .containsKey(constants.defaultKey)) {
              subform = widget.viewModel.findFormByKey(value.decisionNode
                  .conditions[constants.defaultKey][constants.subform]);
            }
            break;
          }
        }
      } else if (widget.field.valuesApi.values.isNotEmpty) {
        for (FrameworkFormFieldValue value in widget.field.valuesApi.values) {
          if (_selectedValue == value.value) {
            if (value.decisionNode.conditions
                .containsKey(constants.defaultKey)) {
              subform = widget.viewModel.findFormByKey(value.decisionNode
                  .conditions[constants.defaultKey][constants.subform]);
            }
            break;
          }
        }
      }
    }
  }
}
