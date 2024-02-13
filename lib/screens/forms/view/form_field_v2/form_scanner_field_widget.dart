import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../screens/forms/view_model/edittext_view_model.dart';
import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/common_constants.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/util.dart';

class FormScannerFieldWidget extends StatefulWidget {
  const FormScannerFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormScannerFieldWidget> createState() => _FormScannerFieldWidgetState();
}

class _FormScannerFieldWidgetState extends State<FormScannerFieldWidget> {
  late TextEditingController textEditingController;
  String initValue = '';
  TextInputType keyboardType = TextInputType.text;
  List<TextInputFormatter> inputFormatters = [];
  late EditTextViewModel editTextViewModel;
  bool isFocused = true;
  final int numberType = 2;

  static const String OUTLINED_TYPE = 'outlined';
  static const String FILLED_TYPE = 'filled';
  String? errorMessage;

  @override
  void initState() {
    editTextViewModel = Provider.of<EditTextViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      editTextViewModel.setLength(widget.field.key, initValue.length);
    });

    /// Initializing edittext value
    _initEdittextValue();

    /// Initialize edittext keyboard type and validations
    _initEdittextKeyboard();

    /// Widget
    /// 1. The widget can be editable by the user
    /// 2. If it is not editable, then we just show the label and the user entered value
    /// 3. If it is not editable, and the user has not entered any value, then
    /// nothing is rendered
    return widget.field.isEditable
        ? Padding(
            padding: EdgeInsets.fromLTRB(
                0.0,
                Util.instance.getTopMargin(widget.field.style),
                0.0,
                constants.mediumPadding),
            child: textField(),
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
      autovalidateMode: AutovalidateMode.always,
      enabled: widget.field.isEditable,
      cursorColor: Colors.black,
      controller: textEditingController,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      showCursor: isFocused,
      enableSuggestions: false,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      decoration: decoration(widget.field.matUiType),
      validator: (value) {
        return validation(value);
      },
      onChanged: (value) {
        editTextViewModel.setLength(widget.field.key, value.length);
        AppState.instance.addToFormTempMap(widget.field.key, value.trim());
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
        labelText: widget.field.label,
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
    return IconButton(
      icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
      onPressed: () {
        widget.viewModel.scanBarcode(widget.field, context);
      },
    );
  }

  String? validation(String? value) {
    if (widget.viewModel.errorWidgetMap.containsKey(widget.field.key)) {
      String? errorMsg = widget.viewModel.errorWidgetMap[widget.field.key];
      if (textEditingController.text.isNotEmpty) {
        widget.viewModel.errorWidgetMap.remove(widget.field.key);
        return null;
      }
      widget.viewModel.scrollToFirstValidationErrorWidget(context);
      errorMessage = errorMsg;
      return errorMsg;
    }
    return null;
  }

  /// This method is called to initialize edittext value
  _initEdittextValue() {
    if (widget.field.isEditable &&
        AppState.instance.formTempMap.containsKey(widget.field.key)) {
      initValue = AppState.instance.formTempMap[widget.field.key];
      textEditingController = TextEditingController(text: initValue);
      textEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
    } else if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.field.key)) {
      initValue = widget.viewModel.clickedSubmissionValuesMap[widget.field.key];
      textEditingController = TextEditingController(text: initValue);
      textEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
    } else {
      textEditingController = TextEditingController();
    }
  }

  _initEdittextKeyboard() {
    if (widget.field.max != null && widget.field.max! > 0) {
      inputFormatters.add(LengthLimitingTextInputFormatter(widget.field.max!));
    }
    if (widget.field.type == numberType) {
      if (Platform.isAndroid) {
        keyboardType = TextInputType.number;
      } else {
        keyboardType =
            const TextInputType.numberWithOptions(signed: true, decimal: true);
      }
      inputFormatters.add(
        FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
      );
    }
  }
}
