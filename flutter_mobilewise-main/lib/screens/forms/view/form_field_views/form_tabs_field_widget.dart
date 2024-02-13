import 'package:flutter/material.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/form_renderer_util.dart';

/// This widget is used to create a tabs view in the UI.
/// The user can click on a tab to make it the active tab and its subform will
/// be used to render all the children below it.
/// A tab should only be visible if it contains a default subform, or if the
/// defined source(s) within the decision node has been selected by the user,
/// and a valid subform exists for that selection.
class FormTabsFieldWidget extends StatefulWidget {
  const FormTabsFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormTabsFieldWidget> createState() => _FormTabsFieldWidgetState();
}

class _FormTabsFieldWidgetState extends State<FormTabsFieldWidget> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.getScrollController().jumpTo(0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              0.0,
              constants.mediumPadding,
              0.0,
              constants.largePadding,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: _getTabs(),
            ),
          ),
          Column(
            children: _getTabChildren(),
          ),
        ],
      ),
    );
  }

  /// This is used to render the row containing the tabs. Tabs are clickable.
  _getTabs() {
    List<Widget> widgets = <Widget>[];
    for (FrameworkFormFieldValue value in widget.field.values) {
      if (_shouldShowTab(value)) {
        widgets.add(Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedIndex = widget.field.values.indexOf(value);
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    0.0,
                    0.0,
                    0.0,
                    constants.smallPadding,
                  ),
                  child: Text(
                    value.value,
                    style: widget.field.values.indexOf(value) == _selectedIndex
                        ? constants.tabSelectedTextStyle
                        : constants.tabUnselectedTextStyle,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        height: constants.horizontalSeparatorHeight * 3,
                        color: widget.field.values.indexOf(value) ==
                                _selectedIndex
                            ? Colors.black
                            : const Color(constants.formFieldBackgroundColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
      }
    }

    /// If there is only one tab, making it occupy only half the screen width
    if (widgets.length == 1) {
      widgets.add(const Expanded(child: SizedBox()));
    }
    return widgets;
  }

  /// A tab should only be visible if it contains a default subform, or if the
  /// defined source(s) within the decision node has been selected by the user,
  /// and a valid subform exists for that selection.
  _shouldShowTab(FrameworkFormFieldValue value) {
    bool shouldShow = false;

    if (value.decisionNode.conditions.containsKey(constants.defaultKey)) {
      /// Default subform exists
      shouldShow = true;
    } else {
      /// Checking if a subform exists for the user selected value (mentioned
      /// in source)
      /// TODO - Only supports one source, add support for multiple
      String key = value.decisionNode.sources[0];
      String userEnteredValue = '';
      if (widget.viewModel.clickedSubmissionValuesMap.containsKey(key)) {
        userEnteredValue = widget.viewModel.clickedSubmissionValuesMap[key];
      } else if (AppState.instance.formTempMap.containsKey(key)) {
        userEnteredValue = AppState.instance.formTempMap[key];
      }
      if (value.decisionNode.conditions.containsKey(userEnteredValue)) {
        shouldShow = true;
      }
    }
    return shouldShow;
  }

  /// This returns the fields that need to be rendered below the tabs.
  _getTabChildren() {
    int index = 0;
    DecisionNode decisionNode = const DecisionNode(sources: [], conditions: {});
    List<Widget> widgets = <Widget>[];

    /// Checking for the selected tab
    for (FrameworkFormFieldValue value in widget.field.values) {
      if (index == _selectedIndex) {
        decisionNode = value.decisionNode;
      }
      index++;
    }
    if (decisionNode.conditions.isNotEmpty) {
      /// Check if the decision node contains any sources
      /// TODO - Only supports one source, add support for multiple
      if (decisionNode.sources.isNotEmpty) {
        String key = decisionNode.sources[0];
        String userEnteredValue = '';
        if (widget.viewModel.clickedSubmissionValuesMap.containsKey(key)) {
          userEnteredValue = widget.viewModel.clickedSubmissionValuesMap[key];
        } else if (AppState.instance.formTempMap.containsKey(key)) {
          userEnteredValue = AppState.instance.formTempMap[key];
        }
        if (userEnteredValue != null &&
            userEnteredValue.isNotEmpty &&
            decisionNode.conditions.containsKey(userEnteredValue)) {
          FrameworkForm subForm = widget.viewModel.findFormByKey(
              decisionNode.conditions[userEnteredValue][constants.subform]);
          List<FocusNode> focusList = [];
          for (FrameworkFormField field in subForm.fields) {
            focusList.add(FocusNode());
            widgets.add(FormRendererUtil.instance
                .getFormFieldWidget(field, widget.viewModel, focusList));
          }
        } else {
          /// Does not contain any source, load default form
          FrameworkForm subForm = widget.viewModel.findFormByKey(
              decisionNode.conditions[constants.defaultKey][constants.subform]);
          List<FocusNode> focusList = [];
          for (FrameworkFormField field in subForm.fields) {
            focusList.add(FocusNode());
            widgets.add(FormRendererUtil.instance
                .getFormFieldWidget(field, widget.viewModel, focusList));
          }
        }
      } else {
        /// Does not contain any source, load default form
        FrameworkForm subForm = widget.viewModel.findFormByKey(
            decisionNode.conditions[constants.defaultKey][constants.subform]);
        List<FocusNode> focusList = [];
        for (FrameworkFormField field in subForm.fields) {
          focusList.add(FocusNode());
          widgets.add(FormRendererUtil.instance
              .getFormFieldWidget(field, widget.viewModel, focusList));
        }
      }
    }
    return widgets;
  }
}
