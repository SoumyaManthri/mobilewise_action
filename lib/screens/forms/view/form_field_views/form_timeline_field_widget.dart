import 'package:flutter/material.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/util.dart';

/// This widget is used to show the possible states of the project.
/// It depicts the states that have been completed with a green thumb indicator.
/// The current state is indicated with an orange thumb indicator, and
/// the future states are depicted with a grey thumb indicator.
class FormTimelineFieldWidget extends StatefulWidget {
  const FormTimelineFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormTimelineFieldWidget> createState() =>
      _FormTimelineFieldWidgetState();
}

class _FormTimelineFieldWidgetState extends State<FormTimelineFieldWidget>
    with SingleTickerProviderStateMixin {
  String currentStatus = '';
  Map<String, dynamic> statusHistory = {};
  AnimationController? refreshController;

  @override
  void initState() {
    super.initState();
    refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  /// Order the history map in the way it needs to be rendered on the widget
  _sortStatusHistoryMap() {
    /// Get the status map of the widget
    Map<String, dynamic> tempMap = {};
    statusHistory.clear();
    if (widget.field.timelineHistoryKey.isNotEmpty &&
        widget.viewModel.clickedSubmissionValuesMap
            .containsKey(widget.field.timelineHistoryKey)) {
      tempMap = widget.viewModel
          .clickedSubmissionValuesMap[widget.field.timelineHistoryKey];
    }
    if (tempMap.isNotEmpty) {
      for (int i = 0; i < widget.field.values.length; i++) {
        if (tempMap.containsKey(widget.field.values[i].value)) {
          statusHistory[widget.field.values[i].value] =
              tempMap[widget.field.values[i].value];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.field.key)) {
      currentStatus =
          widget.viewModel.clickedSubmissionValuesMap[widget.field.key];
    } else if (widget.field.defaultValue.isNotEmpty) {
      currentStatus = widget.field.defaultValue;
    }
    /// Get the current status of the widget
    _sortStatusHistoryMap();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: _getTimelineChildren(),
    );
  }

  _getTimelineChildren() {
    List<Widget> widgets = [];
    bool colorFlag = false;
    Color currentColor;

    for (int i = 0; i < statusHistory.keys.length; i++) {
      String key = statusHistory.keys.elementAt(i);
      Map<String, dynamic> entryMap = statusHistory[key];

      if (currentStatus == key) {
        currentColor = Colors.orange;
        colorFlag = true;
      } else {
        if (colorFlag) {
          currentColor = Colors.grey;
        } else {
          currentColor = Colors.green;
        }
      }

      /// Green if last status is reached
      if (i == (statusHistory.length - 1)) {
        if (currentStatus == key) {
          currentColor = Colors.green;
        }
      }

      widgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: constants.timelineCircleWidth,
                height: constants.timelineCircleWidth,
                decoration: BoxDecoration(
                  color: currentColor, // border color
                  shape: BoxShape.circle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  constants.timelineRectangleWidth,
                  0.0,
                  0.0,
                  0.0,
                ),
                child: Container(
                  width: constants.timelineRectangleWidth,
                  height: constants.timelineItemHeight -
                      constants.timelineCircleWidth,
                  color: i != (statusHistory.length - 1)
                      ? Colors.grey
                      : Colors.transparent,
                ),
              ),
            ],
          ),
          const SizedBox(
            width: constants.mediumPadding,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: _getSubformWidgets(key, entryMap),
          ),
        ],
      ));
    }
    return widgets;
  }

  _getSubformWidgets(String value, Map<String, dynamic> entryMap) {
    List<Widget> widgets = <Widget>[];

    /// Status value
    widgets.add(Text(
      value,
      style: constants.tabSelectedTextStyle,
    ));

    /// Padding
    widgets.add(const SizedBox(
      height: constants.smallPadding,
    ));

    /// Check if subform exists
    if (widget.field.subform.isNotEmpty) {
      FrameworkForm subform =
          widget.viewModel.findFormByKey(widget.field.subform);
      if (subform.formKey.isNotEmpty) {
        /// Subform exists timeline item
        widgets.addAll(_renderTimelineItemWidgets(subform, entryMap));
      }
    }
    return widgets;
  }

  _renderTimelineItemWidgets(
      FrameworkForm subform, Map<String, dynamic> entryMap) {
    List<Widget> widgets = <Widget>[];
    for (FrameworkFormField field in subform.fields) {
      if (field.uiType == constants.row) {
        FrameworkForm rowSubform =
            widget.viewModel.findFormByKey(field.subform);
        if (subform.formKey.isNotEmpty) {
          widgets.add(Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: _renderTimelineItemWidgets(rowSubform, entryMap),
          ));
        }
      } else if (field.uiType == constants.historyText) {
        widgets.add(_historyTextWidget(field, entryMap));
      }
    }
    return widgets;
  }

  /// This is a special field for the timeline item layout
  /// This contains the transaction history for the timeline widget
  _historyTextWidget(FrameworkFormField field, Map<String, dynamic> entryMap) {
    if (field.key.isNotEmpty && field.key.split('#').length == 2) {
      /// The '#' separates the key for the status history field and the
      /// text field we're trying to show
      List<String> keys = field.key.split('#');
      String key2 = keys[1];
      if (entryMap.containsKey(key2)) {
        /// We have a value to render
        String value = '';
        if (key2 == 'datetime') {
          /// Convert timestamp to local date time in 24 hours format
          String timestamp = entryMap[key2]!;
          value = Util.instance.getLocalDateTimeIn24(timestamp);
        } else {
          value = entryMap[key2]!;
        }
        if (value != null && value.isNotEmpty) {
          double textSize = field.textSize.toDouble();
          String style = field.textStyle;
          Map<String, dynamic> colorMap = field.textColor;
          late Color color;

          /// Setting color
          if (colorMap.containsKey(value)) {
            color = Color(int.parse('FF${colorMap[value]}', radix: 16));
          } else if (colorMap.containsKey(constants.defaultKey)) {
            color = Color(
                int.parse('FF${colorMap[constants.defaultKey]}', radix: 16));
          } else {
            color = Colors.black;
          }

          /// Setting text style
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
          return field.icon.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0.0, 0.0, constants.smallPadding, constants.smallPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            0.0, 0.0, constants.xSmallPadding, 0.0),
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
                        value.length > 20
                            ? '${value.substring(0, 20)}...'
                            : value,
                        style: s,
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0.0, 0.0, 0.0, constants.smallPadding),
                  child: Text(
                    value.length > 20 ? '${value.substring(0, 20)}...' : value,
                    style: s,
                  ),
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
  }
}
