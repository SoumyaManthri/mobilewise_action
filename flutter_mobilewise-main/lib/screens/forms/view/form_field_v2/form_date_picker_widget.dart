import 'package:flutter/material.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/common_constants.dart';
import '../../../../utils/hex_color.dart';
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
  final TextEditingController _textEditingController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String initValue = '';

  static const String OUTLINED_TYPE = 'outlined';
  static const String FILLED_TYPE = 'filled';
  FocusNode myfocus = FocusNode();

  String? errorMessage;

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
            child: textField())
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

  TextFormField textField() {
    return TextFormField(
      readOnly: false,
      focusNode: myfocus,
      autovalidateMode: AutovalidateMode.always,
      enabled: widget.field.isEditable,
      showCursor: false,
      controller: _textEditingController,
      keyboardType: TextInputType.none,
      enableInteractiveSelection: false,
      enableSuggestions: false,
      onTap: () {
        myfocus.unfocus();
        _selectDate(context);
      },
      autocorrect: false,
      decoration: decoration(widget.field.matUiType),
      validator: (value) {
        return validation(value);
      },
    );
  }

  InputDecoration decoration(String type) {
    switch (type) {
      case FILLED_TYPE:
        return borderFilled();

      case OUTLINED_TYPE:
      default:
        return borderOutlined();
    }
  }

  InputDecoration borderOutlined() {
    return InputDecoration(
        label: constants.mandatoryField(widget.field),
        // labelText: widget.field.label,
        hintText: widget.field.hint,
        helperText: errorMessage,
        fillColor: HexColor(AppState.instance.themeModel.backgroundColor),
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(
              width: 2,
              color: HexColor(AppState.instance.themeModel.primaryColor)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              width: 2,
              color: HexColor(AppState.instance.themeModel.primaryColor)),
        ),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.red)),
        floatingLabelStyle: TextStyle(
            color: HexColor(AppState.instance.themeModel.primaryColor)),
        labelStyle: const TextStyle(color: Colors.black),
        errorStyle: const TextStyle(color: Colors.red),
        suffixIcon: sufficIcon());
  }

  InputDecoration borderFilled() {
    FrameworkFormStyle? style = widget.field.style;
    return InputDecoration(
        labelText: widget.field.label,
        hintText: widget.field.hint,
        helperText: errorMessage,
        fillColor: HexColor(AppState.instance.themeModel.backgroundColor),
        filled: true,
        border: UnderlineInputBorder(
          borderSide: BorderSide(
              width: 2,
              color: HexColor(AppState.instance.themeModel.primaryColor)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              width: 2,
              color: HexColor(AppState.instance.themeModel.primaryColor)),
        ),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.red)),
        floatingLabelStyle: TextStyle(
            color: HexColor(AppState.instance.themeModel.primaryColor)),
        labelStyle: style != null
            ? applyStyleV2(
                bold: style.bold,
                underline: style.underline,
                italics: style.italics,
                color: style.color,
                size: style.size)
            : null,
        errorStyle: const TextStyle(color: Colors.red),
        suffixIcon: sufficIcon());
  }

  sufficIcon() {
    return const Icon(Icons.calendar_month_outlined, color: Colors.black);
  }

  String? validation(String? value) {
    if (widget.viewModel.errorWidgetMap.containsKey(widget.field.key)) {
      String? errorMsg = widget.viewModel.errorWidgetMap[widget.field.key];
      if (_textEditingController.text.isNotEmpty) {
        widget.viewModel.errorWidgetMap.remove(widget.field.key);
        return null;
      }
      widget.viewModel.scrollToFirstValidationErrorWidget(context);
      errorMessage = errorMsg;
      return errorMsg;
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 100),
      lastDate: DateTime(DateTime.now().year + 100),
      initialDate: _selectedDate,
      helpText:
          widget.field.hint.isNotEmpty ? widget.field.hint : 'Select Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: HexColor(AppState.instance.themeModel.primaryColor),
              onPrimary: HexColor(AppState.instance.themeModel.backgroundColor),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: HexColor(AppState
                    .instance.themeModel.primaryColor), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

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
