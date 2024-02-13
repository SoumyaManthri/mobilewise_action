import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/utils/hex_color.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/common_constants.dart';
import '../../../../utils/util.dart';

class FormDatePickerWidget extends StatefulWidget {
  const FormDatePickerWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormDatePickerWidget> createState() => _FormDatePickerWidgetState();
}

class _FormDatePickerWidgetState extends State<FormDatePickerWidget> {
  TextEditingController _textEditingController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String initValue = '';

  @override
  void initState() {
    super.initState();
    if (widget.field.isEditable &&
        AppState.instance.formTempMap.containsKey(widget.field.key)) {
      _selectedDate = AppState.instance.formTempMap[widget.field.key];
      String convertedDate = Util.instance.getDisplayDate(_selectedDate);
      _textEditingController.text = convertedDate;
      initValue = convertedDate;
    } else if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.field.key)) {
      int ts = int.parse(
          widget.viewModel.clickedSubmissionValuesMap[widget.field.key]);
      _selectedDate = DateTime.fromMillisecondsSinceEpoch(ts);
      String convertedDate = Util.instance.getDisplayDate(_selectedDate);
      _textEditingController.text = convertedDate;
      initValue = convertedDate;
    }

    widget.viewModel.datePickerFields[widget.field.key] = widget.field;
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
                                style: applyStyle(widget.field.style),
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
                                _selectDate(context);
                              },
                              child: TextFormField(
                                enabled: false,
                                cursorColor: Colors.black,
                                controller: _textEditingController,
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

                            /// Show validation error on field if any
                            validationErrorWidget(),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _selectDate(context);
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
                      padding: const EdgeInsets.fromLTRB(0.0,
                          constants.smallPadding, 0.0, constants.smallPadding),
                      child: Text(
                        initValue,
                        style: constants.normalBlackTextStyle,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now());
    if (picked != null && picked != _selectedDate) {
      setState(() {
        widget.viewModel.errorWidgetMap.remove(widget.field.key);
        _selectedDate = picked;
        String convertedDate = Util.instance.getDisplayDate(_selectedDate);
        _textEditingController.text = convertedDate;
        AppState.instance.addToFormTempMap(widget.field.key, _selectedDate);
      });
    }
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
