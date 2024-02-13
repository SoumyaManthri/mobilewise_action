import 'package:flutter/material.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/util.dart';

class FormDateRangeWidget extends StatefulWidget {
  const FormDateRangeWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormDateRangeWidget> createState() => _FormDateRangeWidgetState();
}

class _FormDateRangeWidgetState extends State<FormDateRangeWidget> {
  TextEditingController textEditingController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime todayDate = DateTime.now();
  String initValue = '';

  @override
  void initState() {
    super.initState();
    if (widget.field.isEditable &&
        AppState.instance.formTempMap.containsKey(widget.field.key)) {
      String value = AppState.instance.formTempMap[widget.field.key];
      List<String> dateRange = value.split('#');
      startDate = DateTime.parse(dateRange[0]);
      endDate = DateTime.parse(dateRange[1]);
      String startDateString = Util.instance.getDisplayDate(startDate);
      String endDateString = Util.instance.getDisplayDate(endDate);
      textEditingController.text = '$startDateString - $endDateString';
      initValue = '$startDateString - $endDateString';
    } else if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.field.key)) {
      String value =
          widget.viewModel.clickedSubmissionValuesMap[widget.field.key];
      List<String> dateRange = value.split(',');
      startDate = DateTime.parse(dateRange[0]);
      endDate = DateTime.parse(dateRange[1]);
      String startDateString = Util.instance.getDisplayDate(startDate);
      String endDateString = Util.instance.getDisplayDate(endDate);
      textEditingController.text = '$startDateString - $endDateString';
      initValue = '$startDateString - $endDateString';
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.field.isEditable
        ? Padding(
            padding: EdgeInsets.fromLTRB(
                0.0,
                Util.instance.getTopMargin(widget.field.style),
                0.0,
                constants.mediumPadding),
            child: Material(
              elevation: constants.formComponentsElevation,
              borderRadius: constants.materialBorderRadius,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: constants.dropdownContainerDecoration,
                child: Padding(
                  padding: const EdgeInsets.all(constants.mediumPadding),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: widget.field.label,
                                style: constants.normalGreyTextStyle,
                                children: <TextSpan>[
                                  // Red * to show if the field is mandatory
                                  TextSpan(
                                    text: widget.field.isMandatory ? ' *' : '',
                                    style: constants.normalRedTextStyle,
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _selectDateRange(context);
                              },
                              child: TextFormField(
                                enabled: false,
                                cursorColor: Colors.black,
                                controller: textEditingController,
                                style: constants.normalBlackTextStyle,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: widget.field.hint,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _selectDateRange(context);
                        },
                        child: const SizedBox(
                          width: constants.appBarHeaderIconDimension,
                          height: constants.appBarHeaderIconDimension,
                          child: Image(
                            image: AssetImage(constants.calendar),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : initValue.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(constants.mediumPadding),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: widget.field.label,
                              style: constants.normalGreyTextStyle,
                              children: <TextSpan>[
                                // Red * to show if the field is mandatory
                                TextSpan(
                                  text: widget.field.isMandatory ? ' *' : '',
                                  style: constants.normalRedTextStyle,
                                ),
                              ],
                            ),
                          ),
                          TextFormField(
                            enabled: false,
                            cursorColor: Colors.black,
                            controller: textEditingController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: widget.field.hint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    String startDateString = '';
    String endDateString = '';
    final DateTime? start = await showDatePicker(
      context: context,
      helpText: constants.selectStartDate,
      initialDate: todayDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            textTheme: const TextTheme(overline: TextStyle(fontSize: 16.0)),
          ),
          child: child!,
        );
      },
    );
    if (start != null) {
      startDate = start;
      startDateString = Util.instance.getDisplayDate(startDate);
      final DateTime? end = await showDatePicker(
        context: context,
        helpText: constants.selectEndDate,
        initialDate: startDate,
        firstDate: startDate,
        lastDate: DateTime.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData(
              textTheme: const TextTheme(overline: TextStyle(fontSize: 16.0)),
            ),
            child: child!,
          );
        },
      );
      if (end != null) {
        setState(() {
          endDate = end;
          endDateString = Util.instance.getDisplayDate(endDate);
          textEditingController.text = '$startDateString - $endDateString';
          AppState.instance
              .addToFormTempMap(widget.field.key, '$startDate#$endDate');
        });
      }
    }
  }
}
