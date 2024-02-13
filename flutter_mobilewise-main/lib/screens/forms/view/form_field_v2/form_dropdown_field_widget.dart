import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/util.dart';
import '../../view_model/form_view_model.dart';
import '../form_field_v2/custom_drop_down.dart';
import '../form_field_views/form_subform_field_widget.dart';

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
                      borderRadius: constants.materialBorderRadius,
                      child: CustomDropDown(
                          dropdownValues,
                          _textEditingController,
                          _selectedValue,
                          widget.fieldKey,
                          widget.field,
                          widget.viewModel,
                          widget.position,
                          widget.focusList,
                          _createSubformForSelectedValue),
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
                        constants.mandatoryField(widget.field),
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

  _createSubformForSelectedValue(String _selectedValue) {
    setState(() {
      subform = FormViewModel.emptyFormData();
    });

    if (_selectedValue != null && _selectedValue!.isNotEmpty) {
      /// Checking for a subform for the selected value
      if (widget.field.values.isNotEmpty) {
        for (FrameworkFormFieldValue value in widget.field.values) {
          if (_selectedValue.isNotEmpty) {
            if (_selectedValue == value.value) {
              if (value.decisionNode.conditions
                  .containsKey(constants.defaultKey)) {
                setState(() {
                  subform = widget.viewModel.findFormByKey(value.decisionNode
                      .conditions[constants.defaultKey][constants.subform]);
                });
              }
              break;
            }
          }
        }
      } else if (widget.field.valuesApi.values.isNotEmpty) {
        for (FrameworkFormFieldValue value in widget.field.valuesApi.values) {
          if (_selectedValue.isNotEmpty) {
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
          if (_selectedValue.isNotEmpty) {
            if (_selectedValue[0] == value.value) {
              if (value.decisionNode.conditions
                  .containsKey(constants.defaultKey)) {
                subform = widget.viewModel.findFormByKey(value.decisionNode
                    .conditions[constants.defaultKey][constants.subform]);
              }
              break;
            }
          }
        }
      } else if (widget.field.valuesApi.values.isNotEmpty) {
        for (FrameworkFormFieldValue value in widget.field.valuesApi.values) {
          if (_selectedValue.isNotEmpty) {
            if (_selectedValue[0] == value.value) {
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
}
