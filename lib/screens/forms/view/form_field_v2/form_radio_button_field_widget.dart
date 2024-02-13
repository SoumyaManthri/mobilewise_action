import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/common_constants.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/util.dart';
import '../../../forms/view/form_field_views/form_subform_field_widget.dart';

/// Radio button widget
/// If the selected value is linked to a sub-form through a decision node, then
/// on selection, the form is rendered below the checkbox
class FormRadioButtonFieldWidget extends StatefulWidget {
  const FormRadioButtonFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormRadioButtonFieldWidget> createState() =>
      _FormRadioButtonFieldWidgetState();
}

class _FormRadioButtonFieldWidgetState
    extends State<FormRadioButtonFieldWidget> {
  String selectedValue = '';
  FrameworkForm form =  FormViewModel.emptyFormData();

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
        children: [
          mandatoryField(widget.field),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _getRadioChildren(),
          ),
        ],
      ),
    );
  }

  _getRadioChildren() {
    List<Widget> widgets = <Widget>[];
    if (widget.field.isEditable) {
      /// Radio button is editable
      for (FrameworkFormFieldValue value in widget.field.values) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(
                constants.smallPadding, constants.smallPadding, 0.0, 0.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0.0, 0.0, constants.mediumPadding, 0.0),
                  child: SizedBox(
                    width: constants.closeIconDimension,
                    height: constants.closeIconDimension,
                    child: Radio(
                      value: value.value,
                      groupValue: selectedValue,
                      activeColor:
                          HexColor(AppState.instance.themeModel.primaryColor),
                      onChanged: (v) {
                        setState(() {
                          /// Checking if the value is linked to a decision node and
                          /// contains a sub-form
                          if (value.decisionNode.conditions
                              .containsKey(constants.defaultKey)) {
                            form = widget.viewModel.findFormByKey(value
                                    .decisionNode
                                    .conditions[constants.defaultKey]
                                [constants.subform]);
                          } else {
                            /// Initializing an empty form so that no sub-form is rendered
                            form =  FormViewModel.emptyFormData();
                          }

                          /// after radio button selection, remove the error field from the map
                          widget.viewModel.errorWidgetMap
                              .remove(widget.field.key);
                          selectedValue = value.value;
                          AppState.instance.addToFormTempMap(
                              widget.field.key, selectedValue);
                        });
                      },
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      /// Checking if the value is linked to a decision node and
                      /// contains a sub-form
                      if (value.decisionNode.conditions
                          .containsKey(constants.defaultKey)) {
                        form = widget.viewModel.findFormByKey(
                            value.decisionNode.conditions[constants.defaultKey]
                                [constants.subform]);
                      } else {
                        /// Initializing an empty form so that no sub-form is rendered
                        form =  FormViewModel.emptyFormData();
                      }

                      /// after radio button selection, remove the error field from the map
                      widget.viewModel.errorWidgetMap.remove(widget.field.key);
                      selectedValue = value.value;
                      AppState.instance
                          .addToFormTempMap(widget.field.key, selectedValue);
                    });
                  },
                  child: Text(
                    value.value,
                    style: constants.normalBlackTextStyle,
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      /// Show validation error on field if any
      widgets.add(validationErrorWidget());
    } else {
      /// Radio button is non-editable
      widgets.add(selectedValue.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(
                  constants.mediumPadding,
                  constants.smallPadding,
                  constants.mediumPadding,
                  constants.smallPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.field.label,
                    style: constants.smallGreyTextStyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0,
                        constants.smallPadding, 0.0, constants.smallPadding),
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
      if (!widget.field.isEditable) {
        widgets.add(Padding(
          padding: const EdgeInsets.fromLTRB(
              constants.mediumPadding, 0, constants.mediumPadding, 0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: constants.horizontalSeparatorHeight,
            color: const Color(constants.previewSeparatorColor),
          ),
        ));
      }

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

    /// Adding SizedBox to avoid error if no values exist for the radio widget
    if (widgets.isEmpty) {
      widgets.add(const SizedBox());
    }
    return widgets;
  }

  validationErrorWidget() {
    if (widget.viewModel.errorWidgetMap.containsKey(widget.field.key)) {
      widget.viewModel.scrollToFirstValidationErrorWidget(context);
      return Text(
        widget.viewModel.errorWidgetMap[widget.field.key]!,
        style: constants.smallRedTextStyle,
      );
    } else {
      return const SizedBox();
    }
  }
}
