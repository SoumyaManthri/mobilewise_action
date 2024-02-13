import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../screens/forms/model/server_submission.dart';
import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/util.dart';

class FormDataListWidget extends StatefulWidget {
  const FormDataListWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormDataListWidget> createState() => _FormDataListWidgetState();
}

class _FormDataListWidgetState extends State<FormDataListWidget> {
  List<ServerSubmission> userSubmissions = <ServerSubmission>[];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.fetchSubmissions(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormViewModel>(
      builder: (_, model, child) {
        if (model.isLoading) {
          return child ?? const SizedBox();
        } else if (model.userSubmissions != null) {
          if (model.isFilterApplied) {
            /// Events have been filtered
            userSubmissions = model.filteredSubmissions;
          } else {
            userSubmissions = model.userSubmissions!.submissionList;
          }
          if (!model.isFilterApplied && userSubmissions.isEmpty) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Text(
                  constants.noEvents,
                  style: constants.normalGreyTextStyle,
                ),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.fromLTRB(
                0.0,
                Util.instance.getTopMargin(widget.field.style),
                0.0,
                constants.mediumPadding),
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              widget.field.label,
                              style: constants.dataListLabelTextStyle,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          /// Open filtering form
                          widget.viewModel.dataListButtonPressed(
                              widget.field.dataListFilterSubform);
                        },
                        child: const SizedBox(
                          width: constants.filterIconDimension,
                          height: constants.filterIconDimension,
                          child: Image(
                            image: AssetImage(constants.filterIcon),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: _getDataListItems(),
                ),
              ],
            ),
          );
        } else {
          return child ?? const SizedBox();
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Center(child: constants.getIndicator()),
      ),
    );
  }

  _getDataListItems() {
    FrameworkForm itemSubform =
        widget.viewModel.findFormByKey(widget.field.dataListItemSubform);
    List<Widget> items = <Widget>[];
    if (userSubmissions.isNotEmpty) {
      for (ServerSubmission submission in userSubmissions) {
        items.add(Padding(
            padding: const EdgeInsets.fromLTRB(
              0.0,
              0.0,
              0.0,
              constants.mediumPadding,
            ),
            child: InkWell(
              onTap: () {
                /// Open subform
                AppState.instance.formTempMap.clear();
                widget.viewModel.clickedSubmissionId = submission.submissionId;
                widget.viewModel.clickedSubmissionTs = submission.timestamp;
                widget.viewModel
                    .initClickedSubmissionValuesMap(submission.submissionId);
                widget.viewModel.initializeTempClickedSubmissionValuesMap();
                widget.viewModel
                    .dataListButtonPressed(widget.field.dataListClickSubform);
              },
              child: Material(
                elevation: constants.formComponentsElevation,
                borderRadius: constants.materialBorderRadius,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: constants.dropdownContainerDecoration,
                  child: Padding(
                    padding: const EdgeInsets.all(constants.mediumPadding),
                    child: Column(
                      children: _getDataListItemWidgets(
                          itemSubform, submission.submissionId),
                    ),
                  ),
                ),
              ),
            )));
      }
    } else {
      items.add(SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 1.5,
        child: Center(
          child: Text(
            constants.noEvents,
            style: constants.normalGreyTextStyle,
          ),
        ),
      ));
    }
    return items;
  }

  _getDataListItemWidgets(FrameworkForm itemSubform, String submissionId) {
    List<Widget> widgets = <Widget>[];
    for (FrameworkFormField field in itemSubform.fields) {
      widgets.add(_renderField(field, submissionId));
    }
    return widgets;
  }

  _renderField(FrameworkFormField field, String submissionId) {
    if (field.uiType == constants.dataListText) {
      /// Text field to show data for the current item
      return _dataListTextField(field, submissionId);
    } else if (field.uiType == constants.dataListCollapsible) {
      /// Collapsible field for the current item
      return FormDataListCollapsibleWidget(
          field: field,
          viewModel: widget.viewModel,
          submissionId: submissionId);
    } else if (field.uiType == constants.separator) {
      /// Separator field
      return _separatorField();
    } else if (field.uiType == constants.row) {
      /// Row field
      FrameworkForm subform = widget.viewModel.findFormByKey(field.subform);
      List<Widget> widgets = <Widget>[];
      for (FrameworkFormField field in subform.fields) {
        widgets.add(Expanded(child: _renderField(field, submissionId)));
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: widgets,
      );
    } else if (field.uiType == constants.column) {
      /// Column field
      FrameworkForm subform = widget.viewModel.findFormByKey(field.subform);
      List<Widget> widgets = <Widget>[];
      for (FrameworkFormField field in subform.fields) {
        widgets.add(_renderField(field, submissionId));
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment:
            field.orientation == constants.columnOrientationRight
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: widgets,
      );
    } else {
      return const SizedBox();
    }
  }

  _dataListTextField(FrameworkFormField field, String submissionId) {
    /// Check for current_status_datetime
    String value = '';
    value = _getValue(field, submissionId);
    String defaultValue = field.defaultValue;
    double textSize = field.textSize.toDouble();
    String style = field.textStyle;
    Map<String, dynamic> colorMap = field.textColor;
    late Color color;
    if (value.isNotEmpty) {
      if (colorMap.containsKey(value)) {
        color = Color(int.parse('FF${colorMap[value]}', radix: 16));
      } else if (colorMap.containsKey(constants.defaultKey)) {
        color =
            Color(int.parse('FF${colorMap[constants.defaultKey]}', radix: 16));
      } else {
        color = Colors.black;
      }
    } else if (defaultValue.isNotEmpty) {
      if (colorMap.containsKey(defaultValue)) {
        color = Color(int.parse('FF${colorMap[defaultValue]}', radix: 16));
      } else if (colorMap.containsKey(constants.defaultKey)) {
        color =
            Color(int.parse('FF${colorMap[constants.defaultKey]}', radix: 16));
      } else {
        color = Colors.black;
      }
    } else {
      color = Colors.black;
    }
    TextStyle s = style == constants.bold
        ? TextStyle(
            fontSize: textSize,
            color: color,
            fontWeight: FontWeight.w500,
          )
        : TextStyle(
            fontSize: textSize,
            color: color,
          );
    return value.isNotEmpty || defaultValue.isNotEmpty
        ? field.icon.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(
                    0.0, 0.0, 0.0, constants.smallPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          0.0, 0.0, constants.smallPadding, 0.0),
                      child: SizedBox(
                        width: constants.closeIconDimension,
                        height: constants.closeIconDimension,
                        child: Image(
                          image: AssetImage(field.icon),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Text(
                      value,
                      style: s,
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(
                    0.0, 0.0, 0.0, constants.smallPadding),
                child: Text(
                  value.isEmpty ? defaultValue : value,
                  textAlign:
                      field.orientation == constants.columnOrientationRight
                          ? TextAlign.end
                          : TextAlign.start,
                  style: s,
                ),
              )
        : const SizedBox();
  }

  _separatorField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        0.0,
        0.0,
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

  _getValue(FrameworkFormField field, String submissionId) {
    String value = '';
    if (widget.viewModel.userSubmissionsValuesMap.containsKey(submissionId)) {
      Map<String, dynamic> valuesMap = widget.viewModel
          .userSubmissionsValuesMap[submissionId] as Map<String, dynamic>;
      if (valuesMap.containsKey(field.key)) {
        value = valuesMap[field.key];
      }
    }
    return value;
  }

  _getValueForKey(String key, String submissionId) {
    dynamic value;
    if (widget.viewModel.userSubmissionsValuesMap.containsKey(submissionId)) {
      Map<String, dynamic> valuesMap = widget.viewModel
          .userSubmissionsValuesMap[submissionId] as Map<String, dynamic>;
      if (valuesMap.containsKey(key)) {
        value = valuesMap[key];
      }
    }
    return value;
  }
}

class FormDataListCollapsibleWidget extends StatefulWidget {
  const FormDataListCollapsibleWidget({
    Key? key,
    required this.field,
    required this.viewModel,
    required this.submissionId,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;
  final String submissionId;

  @override
  State<FormDataListCollapsibleWidget> createState() =>
      _FormDataListCollapsibleWidgetState();
}

class _FormDataListCollapsibleWidgetState
    extends State<FormDataListCollapsibleWidget> {
  Map<String, Map<String, bool>> collapsibleViewStatus = {};

  @override
  Widget build(BuildContext context) {
    return _dataListCollapsible(widget.field, widget.submissionId);
  }

  _dataListCollapsible(FrameworkFormField field, String submissionId) {
    String value = '';
    value = _getValue(field, submissionId);
    String defaultValue = field.defaultValue;
    double textSize = field.textSize.toDouble();
    String style = field.textStyle;
    Map<String, dynamic> colorMap = field.textColor;
    late Color color;
    if (value.isNotEmpty) {
      if (colorMap.containsKey(value)) {
        color = Color(int.parse('FF${colorMap[value]}', radix: 16));
      } else if (colorMap.containsKey(constants.defaultKey)) {
        color =
            Color(int.parse('FF${colorMap[constants.defaultKey]}', radix: 16));
      } else {
        color = Colors.black;
      }
    } else if (defaultValue.isNotEmpty) {
      if (colorMap.containsKey(defaultValue)) {
        color = Color(int.parse('FF${colorMap[defaultValue]}', radix: 16));
      } else if (colorMap.containsKey(constants.defaultKey)) {
        color =
            Color(int.parse('FF${colorMap[constants.defaultKey]}', radix: 16));
      } else {
        color = Colors.black;
      }
    } else {
      color = Colors.black;
    }
    TextStyle s = style == constants.bold
        ? TextStyle(
            fontSize: textSize,
            color: color,
            fontWeight: FontWeight.w500,
          )
        : TextStyle(
            fontSize: textSize,
            color: color,
          );
    return value.isNotEmpty || defaultValue.isNotEmpty
        ? field.icon.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(
                    0.0, constants.smallPadding, 0.0, constants.mediumPadding),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (collapsibleViewStatus.containsKey(submissionId)) {
                        Map<String, bool>? valueMap = {};
                        valueMap = collapsibleViewStatus[submissionId];
                        if (valueMap!.containsKey(field.key)) {
                          if (valueMap[field.key]!) {
                            collapsibleViewStatus[submissionId]![field.key] =
                                false;
                          } else {
                            collapsibleViewStatus[submissionId]![field.key] =
                                true;
                          }
                        } else {
                          Map<String, bool> value = {};
                          value[field.key] = true;
                          collapsibleViewStatus[submissionId] = value;
                        }
                      } else {
                        Map<String, bool> value = {};
                        value[field.key] = true;
                        collapsibleViewStatus[submissionId] = value;
                      }
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 0.0, constants.smallPadding, 0.0),
                                child: SizedBox(
                                  width: constants.closeIconDimension,
                                  height: constants.closeIconDimension,
                                  child: Image(
                                    image: AssetImage(field.icon),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Text(
                                value,
                                style: s,
                              ),
                            ],
                          )),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(
                                0.0, 0.0, constants.smallPadding, 0.0),
                            child: Icon(
                              Icons.arrow_drop_down_outlined,
                              size: constants.closeIconDimension,
                              color: Color(constants.collapsibleArrowColor),
                            ),
                          ),
                        ],
                      ),
                      _getCollapsibleSubform(),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(
                    0.0, 0.0, 0.0, constants.smallPadding),
                child: Text(
                  value.isEmpty ? defaultValue : value,
                  textAlign: TextAlign.start,
                  style: s,
                ),
              )
        : const SizedBox();
  }

  _getValue(FrameworkFormField field, String submissionId) {
    String value = '';
    if (widget.viewModel.userSubmissionsValuesMap.containsKey(submissionId)) {
      Map<String, dynamic> valuesMap = widget.viewModel
          .userSubmissionsValuesMap[submissionId] as Map<String, dynamic>;
      if (valuesMap.containsKey(field.key)) {
        value = valuesMap[field.key];
      }
    }
    return value;
  }

  _getCollapsibleSubform() {
    if (collapsibleViewStatus.containsKey(widget.submissionId)) {
      Map<String, bool>? valueMap = {};
      valueMap = collapsibleViewStatus[widget.submissionId];
      if (valueMap!.containsKey(widget.field.key)) {
        if (valueMap[widget.field.key]!) {
          FrameworkForm subform = FormViewModel.emptyFormData();
          subform = widget.viewModel.findFormByKey(widget.field.subform);
          if (subform.formKey.isNotEmpty && subform.fields.isNotEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _renderSubformChildren(subform),
            );
          } else {
            return const SizedBox();
          }
        } else {
          return const SizedBox();
        }
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
  }

  _renderSubformChildren(FrameworkForm itemSubform) {
    List<Widget> widgets = <Widget>[];
    widgets.add(const SizedBox(
      height: constants.smallPadding,
    ));
    for (FrameworkFormField field in itemSubform.fields) {
      widgets.add(_renderField(field));
    }
    return widgets;
  }

  _renderField(FrameworkFormField field) {
    if (field.uiType == constants.dataListText) {
      /// Text field to show data for the current item
      return _dataListTextField(field);
    } else {
      return const SizedBox();
    }
  }

  _dataListTextField(FrameworkFormField field) {
    /// Check for current_status_datetime
    String value = '';
    value = _getValue(field, widget.submissionId);
    String defaultValue = field.defaultValue;
    double textSize = field.textSize.toDouble();
    String style = field.textStyle;
    Map<String, dynamic> colorMap = field.textColor;
    late Color color;
    if (value.isNotEmpty) {
      if (colorMap.containsKey(value)) {
        color = Color(int.parse('FF${colorMap[value]}', radix: 16));
      } else if (colorMap.containsKey(constants.defaultKey)) {
        color =
            Color(int.parse('FF${colorMap[constants.defaultKey]}', radix: 16));
      } else {
        color = Colors.black;
      }
    } else if (defaultValue.isNotEmpty) {
      if (colorMap.containsKey(defaultValue)) {
        color = Color(int.parse('FF${colorMap[defaultValue]}', radix: 16));
      } else if (colorMap.containsKey(constants.defaultKey)) {
        color =
            Color(int.parse('FF${colorMap[constants.defaultKey]}', radix: 16));
      } else {
        color = Colors.black;
      }
    } else {
      color = Colors.black;
    }
    TextStyle s = style == constants.bold
        ? TextStyle(
            fontSize: textSize,
            color: color,
            fontWeight: FontWeight.w500,
          )
        : TextStyle(
            fontSize: textSize,
            color: color,
          );
    return value.isNotEmpty || defaultValue.isNotEmpty
        ? field.icon.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(
                    0.0, 0.0, 0.0, constants.smallPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          0.0, 0.0, constants.smallPadding, 0.0),
                      child: SizedBox(
                        width: constants.closeIconDimension,
                        height: constants.closeIconDimension,
                        child: Image(
                          image: AssetImage(field.icon),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Text(
                      value,
                      style: s,
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(
                    0.0, 0.0, 0.0, constants.smallPadding),
                child: Text(
                  value.isEmpty ? defaultValue : value,
                  textAlign:
                      field.orientation == constants.columnOrientationRight
                          ? TextAlign.end
                          : TextAlign.start,
                  style: s,
                ),
              )
        : const SizedBox();
  }
}
