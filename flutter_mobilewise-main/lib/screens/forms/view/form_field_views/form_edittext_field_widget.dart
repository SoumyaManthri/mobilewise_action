import 'dart:ffi';
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
import '../../../../utils/util.dart';

class FormEdittextFieldWidget extends StatefulWidget {
  const FormEdittextFieldWidget({
    Key? key,
    required this.field,
    required this.fieldKey,
    required this.viewModel,
    required this.position,
    required this.focusList,
  }) : super(key: key);

  final FrameworkFormField field;
  final String fieldKey;
  final FormViewModel viewModel;
  final int position;
  final List<FocusNode>? focusList;

  @override
  State<FormEdittextFieldWidget> createState() =>
      _FormEdittextFieldWidgetState();
}

class _FormEdittextFieldWidgetState extends State<FormEdittextFieldWidget> {
  late TextEditingController textEditingController;
  String initValue = '';
  TextInputType keyboardType = TextInputType.text;
  List<TextInputFormatter> inputFormatters = [];
  late EditTextViewModel editTextViewModel;
  bool isFocused = true;
  final int numberType = 2;
  final int passwordType = 3;
  late bool _textVisible;

  @override
  void initState() {
    editTextViewModel = Provider.of<EditTextViewModel>(context, listen: false);
    _textVisible = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      editTextViewModel.setLength(widget.fieldKey, initValue.length);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Initializing edittext value
    _initEdittextValue();

    /// Initialize edittext keyboard type and validations
    _initEdittextKeyboard();
    if (widget.focusList != null &&
        widget.focusList![widget.position].hasFocus) {
      isFocused = true;
    }

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
            child: Material(
              elevation: constants.formComponentsElevation,
              borderRadius: constants.materialBorderRadius,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: constants.dropdownContainerDecoration,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: constants.dropdownHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(constants.mediumPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        mandatoryField(widget.field),
                        widget.field.type == passwordType
                            ? TextFormField(
                                autovalidateMode: AutovalidateMode.always,
                                enabled: widget.field.isEditable,
                                cursorColor: Colors.black,
                                controller: textEditingController,
                                obscureText: !_textVisible,
                                keyboardType: keyboardType,
                                inputFormatters: inputFormatters,
                                showCursor: isFocused,
                                enableSuggestions: false,
                                autocorrect: false,
                                textInputAction: widget.focusList != null &&
                                        widget.focusList!.length - 1 ==
                                            widget.position
                                    ? TextInputAction.done
                                    : TextInputAction.next,
                                focusNode: widget.focusList![widget.position],
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: widget.field.hint,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _textVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _textVisible = !_textVisible;
                                      });
                                    },
                                  ),
                                ),
                                onFieldSubmitted: (v) {
                                  widget.focusList![widget.position].unfocus();
                                  setState(() {
                                    isFocused = false;
                                  });
                                  if (widget.focusList!.length - 1 >
                                      widget.position) {
                                    if (widget.focusList != null) {
                                      FocusScope.of(context).requestFocus(widget
                                          .focusList![widget.position + 1]);
                                    }
                                  } else {
                                    Future.delayed(
                                        const Duration(milliseconds: 300), () {
                                      SystemChannels.textInput
                                          .invokeMethod('TextInput.hide');
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (widget.viewModel.errorWidgetMap
                                      .containsKey(widget.field.key)) {
                                    String? errorMsg = widget.viewModel
                                        .errorWidgetMap[widget.field.key];
                                    if (textEditingController.text.isNotEmpty) {
                                      widget.viewModel.errorWidgetMap
                                          .remove(widget.field.key);
                                      return null;
                                    }
                                    widget.viewModel
                                        .scrollToFirstValidationErrorWidget(
                                            context);
                                    return errorMsg;
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  editTextViewModel.setLength(
                                      widget.fieldKey, value.length);
                                  AppState.instance.addToFormTempMap(
                                      widget.fieldKey, value.trim());
                                },
                              )
                            : TextFormField(
                                autovalidateMode: AutovalidateMode.always,
                                enabled: widget.field.isEditable,
                                cursorColor: Colors.black,
                                controller: textEditingController,
                                keyboardType: keyboardType,
                                inputFormatters: inputFormatters,
                                showCursor: isFocused,
                                textInputAction: widget.focusList != null &&
                                        widget.focusList!.length - 1 ==
                                            widget.position
                                    ? TextInputAction.done
                                    : TextInputAction.next,
                                focusNode: widget.focusList![widget.position],
                                onFieldSubmitted: (v) {
                                  widget.focusList![widget.position].unfocus();
                                  setState(() {
                                    isFocused = false;
                                  });
                                  if (widget.focusList!.length - 1 >
                                      widget.position) {
                                    if (widget.focusList != null) {
                                      FocusScope.of(context).requestFocus(widget
                                          .focusList![widget.position + 1]);
                                    }
                                  } else {
                                    Future.delayed(
                                        const Duration(milliseconds: 300), () {
                                      SystemChannels.textInput
                                          .invokeMethod('TextInput.hide');
                                    });
                                  }
                                },

                                /// Show validation error on field if any
                                validator: (value) {
                                  if (widget.viewModel.errorWidgetMap
                                      .containsKey(widget.field.key)) {
                                    String? errorMsg = widget.viewModel
                                        .errorWidgetMap[widget.field.key];
                                    if (textEditingController.text.isNotEmpty) {
                                      widget.viewModel.errorWidgetMap
                                          .remove(widget.field.key);
                                      return null;
                                    }
                                    widget.viewModel
                                        .scrollToFirstValidationErrorWidget(
                                            context);
                                    return errorMsg;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: widget.field.hint,
                                ),
                                onChanged: (value) {
                                  editTextViewModel.setLength(
                                      widget.fieldKey, value.length);
                                  AppState.instance.addToFormTempMap(
                                      widget.fieldKey, value.trim());
                                },
                              ),
                        widget.field.max != null && widget.field.max! > 0
                            ? Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Consumer<EditTextViewModel>(
                                      builder: (_, model, child) {
                                    return Text(
                                      '${editTextViewModel.keyToLengthMap[widget.fieldKey] ?? 0}/${widget.field.max!}',
                                      style: constants.smallGreyTextStyle,
                                    );
                                  }),
                                ],
                              )
                            : const SizedBox(),
                      ],
                    ),
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

  /// This method is called to initialize edittext value
  _initEdittextValue() {
    if (widget.field.isEditable &&
        AppState.instance.formTempMap.containsKey(widget.fieldKey)) {
      initValue = AppState.instance.formTempMap[widget.fieldKey];
      textEditingController = TextEditingController(text: initValue);
      textEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
    } else if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.fieldKey)) {
      initValue = widget.viewModel.clickedSubmissionValuesMap[widget.fieldKey];
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
