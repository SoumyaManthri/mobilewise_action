import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/hex_color.dart';
import '../../../../utils/util.dart';
import '../../../../utils/validation_util.dart';

class CustomDropDown extends StatefulWidget {
  CustomDropDown(
      this.dropdownValues,
      this.textEditingController,
      this.selectedValue,
      this.fieldKey,
      this.field,
      this.viewModel,
      this.position,
      this.listFocusNode,
      this.createSubformForSelectedValue,
      {super.key});

  List<String>? dropdownValues;
  TextEditingController textEditingController;
  List<String> selectedValue;
  String fieldKey;
  FrameworkFormField field;
  FormViewModel viewModel;
  int position;
  List<FocusNode>? listFocusNode;
  String? errorMessage;
  Function createSubformForSelectedValue;

  @override
  CustomDropDownState createState() => CustomDropDownState();
}

class CustomDropDownState extends State<CustomDropDown> {
  /// Each dropdown is a floating widget called Overlay and is inserted in the
  /// overlay's stack as an overlay entry.
  late OverlayEntry? _overlayEntry;

  /// This will make the suggestions box follow the TextField wherever it goes.
  final LayerLink _layerLink = LayerLink();
  ValueNotifier<bool> isVisible = ValueNotifier(false);
  bool searchAreaFocusChangeDetected = false;
  var searchableTypeDD = [3, 4];
  var multiSelectTypeDD = [2, 4];
  var isOverlayAlreadyRunning = false;
  static const String OUTLINED_TYPE = 'outlined';
  static const String FILLED_TYPE = 'filled';

  @override
  void initState() {
    super.initState();

    /// Adding listener to the TextFormField to enable search functionality and show
    /// suggestions as user starts typing;
    widget.textEditingController.addListener(() {
      if (widget.textEditingController.text.isNotEmpty) {
        if (isVisible.value == false) {
          isVisible.value = !isVisible.value;
        }
        if (AppState.instance.formTempMap[widget.fieldKey] == null) {
          AppState.instance.addToFormTempMap(
              widget.fieldKey, widget.textEditingController.text);
        } else if (AppState.instance.formTempMap[widget.fieldKey] != null &&
            AppState.instance.formTempMap[widget.fieldKey] !=
                widget.textEditingController.text) {
          AppState.instance.addToFormTempMap(
              widget.fieldKey, widget.textEditingController.text);
        }
      } else {
        AppState.instance.removeFromFormTempMap(widget.fieldKey);
        if (widget.viewModel.dropDownValuesLoaded != null &&
            widget.viewModel.dropDownValuesLoaded
                .containsKey(widget.fieldKey) &&
            widget.viewModel.dropDownValuesLoaded[widget.fieldKey]!) {
          if (!widget.viewModel.dropdownNotLoadedCompletely
              .contains(widget.fieldKey)) {
            widget.viewModel.clickedSubmissionValuesMap.remove(widget.fieldKey);
          }
        }
        if (isVisible.value == true) {
          isVisible.value = !isVisible.value;
        }
      }
      if (!_isMultiSelect()) {
        Util.instance.removeAllDropDownOverlays();
        isOverlayAlreadyRunning = false;
      }

      if (!isOverlayAlreadyRunning && _isMultiSelect()) {
        Util.instance.removeAllDropDownOverlays();
      }

      if (widget.textEditingController.text.isNotEmpty &&
          widget.textEditingController.text !=
              widget.selectedValue.join(', ')) {
        createAndInsertDropDownOverlay(context);
      }
    });
  }

  OverlayEntry _createOverlayEntry(List<String> dropDownValues) {
    final sc = ScrollController();
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    Offset position =
        renderBox.localToGlobal(Offset.zero); // This is global position
    double verticalPositionOfCurrentWidget = position.dy;

    return OverlayEntry(
        builder: (context) => Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(
                    0.0,

                    /// Logic to position the dropdown overlays as per the position of widget in screen.
                    /// For example if textFormField is below on the screen, show the dropdown overlay upward
                    verticalPositionOfCurrentWidget > 400
                        ? dropDownValues.length <= 5
                            ? -dropDownValues.length *
                                constants.searchableDropdownItemHeight
                            : -constants.searchableDropdownMaxHeight
                        : size.height - 5.0),
                child: Material(
                  elevation: constants.formComponentsElevation,
                  borderRadius: constants.materialBorderRadius,
                  child: Container(
                    /// Show the dropdown height according to the items.
                    height: dropDownValues.length <= 5
                        ? dropDownValues.length *
                            constants.searchableDropdownItemHeight
                        : constants.searchableDropdownMaxHeight,
                    decoration: constants.dropdownItemDecoration,
                    child: MediaQuery.removePadding(
                      /// To remove extra padding over scrollbar
                      removeTop: true,
                      context: context,
                      child: Scrollbar(
                        controller: sc,
                        thumbVisibility: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          controller: sc,
                          padding: const EdgeInsets.all(0.0),
                          itemCount: dropDownValues.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option =
                                dropDownValues.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                if (!_isMultiSelect()) {
                                  Future.delayed(
                                      const Duration(milliseconds: 300), () {
                                    SystemChannels.textInput
                                        .invokeMethod('TextInput.hide');
                                  });
                                  setState(() {
                                    widget.selectedValue = [option];
                                    widget.textEditingController.text = option;
                                    widget
                                        .createSubformForSelectedValue(option);
                                  });
                                }
                              },
                              child: ListTile(
                                /// To remove extra padding
                                trailing:
                                    _isMultiSelect() ? _checkBox(option) : null,
                                visualDensity: const VisualDensity(
                                    horizontal: 0, vertical: -2),
                                title: Text(option,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ));
  }

  void clearTextAndShowSuggestions() {
    widget.selectedValue.clear();
    widget.textEditingController.clear();
    widget.createSubformForSelectedValue("");
    AppState.instance.removeFromFormTempMap(widget.fieldKey);
    if (widget.viewModel.dropDownValuesLoaded != null &&
        widget.viewModel.dropDownValuesLoaded.containsKey(widget.fieldKey) &&
        widget.viewModel.dropDownValuesLoaded[widget.fieldKey]!) {
      widget.viewModel.clickedSubmissionValuesMap.remove(widget.fieldKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentText = widget.textEditingController.text;
    widget.textEditingController.text =
        widget.selectedValue.join(', ') ?? currentText;
    widget.textEditingController.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.textEditingController.text.length));
    if (Platform.isIOS) {
      widget.listFocusNode![widget.position].addListener(() {
        searchAreaFocusChangeDetected = true;
      });
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: getTextField(),
    );
  }

  TextFormField getTextField() {
    return TextFormField(
      readOnly: !_isSearchable(),
      autovalidateMode: AutovalidateMode.always,
      cursorColor: Colors.black,
      controller: widget.textEditingController,
      focusNode: widget.listFocusNode![widget.position],
      onTap: _isSearchable()
          ? null
          : () {
              widget.listFocusNode![widget.position - 1].unfocus();
              Util.instance.removeAllDropDownOverlays();
              if (isOverlayAlreadyRunning == false) {
                if (searchAreaFocusChangeDetected && Platform.isIOS) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    createAndInsertDropDownOverlay(context);
                    searchAreaFocusChangeDetected = false;
                  });
                } else {
                  createAndInsertDropDownOverlay(context);
                }
              } else {
                isOverlayAlreadyRunning = false;
              }
            },
      onFieldSubmitted: (v) {
        isOverlayAlreadyRunning = false;
        Util.instance.removeAllDropDownOverlays();
        if (widget.listFocusNode!.length - 1 > widget.position) {
          if (!widget.field.allowCustomEntry &&
              !widget.dropdownValues!
                  .contains(widget.textEditingController.text)) {
            widget.textEditingController.clear();
            AppState.instance.removeFromFormTempMap(widget.fieldKey);
          }
          if (widget.listFocusNode != null) {
            FocusScope.of(context)
                .requestFocus(widget.listFocusNode![widget.position + 1]);
          }
        } else {
          if (!widget.field.allowCustomEntry &&
              !widget.dropdownValues!
                  .contains(widget.textEditingController.text)) {
            widget.textEditingController.clear();
            AppState.instance.removeFromFormTempMap(widget.fieldKey);
          }
          Future.delayed(const Duration(milliseconds: 300), () {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          });
        }
        if (v.isNotEmpty && _isMultiSelect()) {
          widget.selectedValue = [v];
        }
      },
      textInputAction: widget.listFocusNode!.length - 1 == widget.position
          ? TextInputAction.done
          : TextInputAction.next,
      validator: (value) {
        return validation(value);
      },
      decoration: decoration(widget.field.matUiType),
    );
  }

  String? validation(String? value) {
    if (widget.viewModel.errorWidgetMap.containsKey(widget.field.key)) {
      String? errorMsg = widget.viewModel.errorWidgetMap[widget.field.key];
      if (ValidationUtil.isValidItem(
          widget.field, widget.textEditingController.text, widget.viewModel)) {
        widget.viewModel.errorWidgetMap.remove(widget.field.key);
        return null;
      }
      widget.viewModel.scrollToFirstValidationErrorWidget(context);
      widget.errorMessage = errorMsg;
      return errorMsg;
    }
    return null;
  }

  InputDecoration decoration(String type) {
    switch (type) {
      case OUTLINED_TYPE:
        return borderOutlined();

      case FILLED_TYPE:
      default:
        return borderFilled();
    }
  }

  InputDecoration borderFilled() {
    FrameworkFormStyle? style = widget.field.style;
    return InputDecoration(
        labelText: widget.field.label,
        hintText: widget.field.hint,
        helperText: widget.errorMessage,
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
            ? constants.applyStyleV2(
                bold: style.bold,
                underline: style.underline,
                italics: style.italics,
                color: style.color,
                size: style.size)
            : null,
        errorStyle: const TextStyle(color: Colors.red),
        suffixIcon: suffixIcon());
  }

  InputDecoration borderOutlined() {
    FrameworkFormStyle? style = widget.field.style;
    return InputDecoration(
        /*labelText: widget.field.isMandatory
            ? widget.field.label+'*'
            : widget.field.label,*/
        label: constants.mandatoryField(widget.field),
        hintText: widget.field.hint,
        helperText: widget.errorMessage,
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
        labelStyle: style != null
            ? constants.applyStyleV2(
                bold: style.bold,
                underline: style.underline,
                italics: style.italics,
                color: style.color,
                size: style.size)
            : null,
        errorStyle: const TextStyle(color: Colors.red),
        suffixIcon: suffixIcon());
  }

  void createAndInsertDropDownOverlay(BuildContext context) {
    List<String> dropDownValues;

    if (_isSearchable()) {
      dropDownValues = widget.dropdownValues != null
          ? widget.dropdownValues!
              .where((String value) => value
                  .toLowerCase()
                  .contains(widget.textEditingController.text.toLowerCase()))
              .toList()
          : [];
    } else {
      dropDownValues = widget.dropdownValues ?? [];
    }

    if (dropDownValues.isNotEmpty) {
      if (!_isMultiSelect()) {
        _overlayEntry = _createOverlayEntry(dropDownValues);
        Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);

        /// Adding all created overlays to a list to access all of them globally.
        Util.instance.addOverlay(_overlayEntry!);
        isOverlayAlreadyRunning = true;
      } else {
        if (isOverlayAlreadyRunning == false) {
          _overlayEntry = _createOverlayEntry(dropDownValues);
          Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);

          /// Adding all created overlays to a list to access all of them globally.
          Util.instance.addOverlay(_overlayEntry!);

          isOverlayAlreadyRunning = true;
        }
      }
    }
  }

  _checkBox(String option) {
    return StatefulBuilder(builder: (context, setState) {
      return Checkbox(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        value: widget.selectedValue.contains(option),
        onChanged: (isSelected) {
          setState(() {
            if (isSelected!) {
              widget.selectedValue.add(option);
            } else {
              widget.selectedValue.remove(option);
            }

            String currentText = widget.textEditingController.text;
            widget.textEditingController.text =
                widget.selectedValue.join(', ') ?? currentText;
            widget.textEditingController.selection = TextSelection.fromPosition(
                TextPosition(offset: widget.textEditingController.text.length));

            // AppState.instance.addToFormTempMap(widget.field.key, selectedValue);
          });
        },
      );
    });
  }

  _isMultiSelect() {
    return multiSelectTypeDD.contains(widget.field.type);
  }

  _isSearchable() {
    return searchableTypeDD.contains(widget.field.type);
  }

  suffixIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
            icon:
                const Icon(Icons.arrow_drop_down_outlined, color: Colors.black),
            onPressed: !_isSearchable()
                ? null
                : () {
                    /// Removes previous dropdown overlays if any.
                    Util.instance.removeAllDropDownOverlays();
                    if (isOverlayAlreadyRunning == false) {
                      if (searchAreaFocusChangeDetected && Platform.isIOS) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          createAndInsertDropDownOverlay(context);
                          searchAreaFocusChangeDetected = false;
                        });
                      } else {
                        createAndInsertDropDownOverlay(context);
                      }
                    } else {
                      isOverlayAlreadyRunning = false;
                    }
                  }),
        ValueListenableBuilder(
          valueListenable: isVisible,
          builder: (context, value, child) {
            if (value != ValueNotifier<bool>(false).value) {
              return IconButton(
                  onPressed: () {
                    clearTextAndShowSuggestions();
                    if (isOverlayAlreadyRunning && _isMultiSelect()) {
                      Util.instance.removeAllDropDownOverlays();
                      isOverlayAlreadyRunning = false;
                    }
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: HexColor(AppState.instance.themeModel.primaryColor),
                  ));
            } else {
              return const SizedBox();
            }
          },
        )
      ],
    );
  }
}
