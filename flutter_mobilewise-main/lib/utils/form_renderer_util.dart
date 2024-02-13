import 'package:flutter/material.dart';

import '../screens/forms/view/form_field_v2/form_address_field_widget.dart';
import '../screens/forms/view/form_field_v2/form_button_field_widget.dart';
import '../screens/forms/view/form_field_v2/form_data_list_widget.dart';
import '../screens/forms/view/form_field_v2/form_date_picker_widget.dart';
import '../screens/forms/view/form_field_v2/form_dropdown_field_widget.dart';
import '../screens/forms/view/form_field_v2/form_edittext_field_widget.dart';
import '../screens/forms/view/form_field_v2/form_field_file_values_widget.dart';
import '../screens/forms/view/form_field_v2/form_field_geotag_values_widget.dart';
import '../screens/forms/view/form_field_v2/form_field_image_values_widget.dart';
import '../screens/forms/view/form_field_v2/form_field_label_values_widget.dart';
import '../screens/forms/view/form_field_v2/form_file_picker_widget.dart';
import '../screens/forms/view/form_field_v2/form_geotag_field_widget.dart';
import '../screens/forms/view/form_field_v2/form_image_field_widget.dart';
import '../screens/forms/view/form_field_v2/form_radio_button_field_widget.dart';
import '../screens/forms/view/form_field_v2/form_scanner_field_widget.dart';
import '../screens/forms/view/form_field_v2/form_separator_field_widget.dart';
import '../screens/forms/view/form_field_v2/form_single_select_checkbox_field_widget.dart';
import '../screens/forms/view/form_field_views/form_column_field_widget.dart';
import '../screens/forms/view/form_field_views/form_date_range_widget.dart';
import '../screens/forms/view/form_field_views/form_image_uploader_widget.dart';
import '../screens/forms/view/form_field_views/form_numeric_field_widget.dart';
import '../screens/forms/view/form_field_views/form_preview_group_field_widget.dart';
import '../screens/forms/view/form_field_views/form_row_field_widget.dart';
import '../screens/forms/view/form_field_views/form_subform_field_widget.dart';
import '../screens/forms/view/form_field_views/form_tabs_field_widget.dart';
import '../screens/forms/view/form_field_views/form_text_field_widget.dart';
import '../screens/forms/view/form_field_views/form_time_preview_field_widget.dart';
import '../screens/forms/view/form_field_views/form_timeline_field_widget.dart';
import '../screens/forms/view_model/form_view_model.dart';
import '../shared/model/framework_form.dart';
import '../utils/common_constants.dart' as constants;
import 'app_state.dart';

class FormRendererUtil {
  static FormRendererUtil? _instance;

  FormRendererUtil._();

  static FormRendererUtil get instance => _instance ??= FormRendererUtil._();

  /// Render form fields based on the UI Type
  Widget getFormFieldWidget(FrameworkFormField field, FormViewModel viewModel,
      List<FocusNode> focusList,
      {String? formType, String? value}) {
    formType = formType ?? viewModel.currentForm.formType;
    if ([constants.dataListDetails, constants.previewFormType]
        .contains(formType)) {
      switch (field.image) {
        case constants.dataListImagePicker:
          return FormFieldImageValuesWidget(field: field, value: value, viewModel: viewModel);
        case constants.dataListFilePicker:
          return FormFieldFileValuesWidget(field: field, value: value, viewModel: viewModel);
        case constants.geotag:
          return FormFieldGeotagValuesWidget(field: field, value: value, viewModel: viewModel);
        default:
          return FormLabelValueFieldWidget(
              field: field, value: value, viewModel: viewModel);
      }
    }

    if (AppState.instance.userPermissions != null &&
        !AppState
            .instance.userPermissions!.permissions[constants.appId]!.resources
            .containsKey(field.key)) {
      return const SizedBox();
    }
    if (field.uiType == constants.dropdown) {
      /// Dropdown
      return FormDropdownFieldWidget(
        key: Key(field.key),
        field: field,
        fieldKey: field.key,
        viewModel: viewModel,
        position: focusList.length - 1,
        focusList: focusList,
      );
    } else if (field.uiType == constants.edittext) {
      /// Text box
      return FormEdittextFieldWidget(
        key: Key(field.key),
        field: field,
        fieldKey: field.key,
        viewModel: viewModel,
        position: focusList.length - 1,
        focusList: focusList,
      );
    } else if (field.uiType == constants.address) {
      /// Address box
      return FormAddressFieldWidget(
        key: Key(field.key),
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.numericEdittext) {
      /// Numeric Text box(With increment and decrement buttons)
      return FormNumericFieldWidget(
        key: Key(field.key),
        field: field,
        fieldKey: field.key,
        viewModel: viewModel,
        position: focusList.length - 1,
        focusList: focusList,
      );
    } else if (field.uiType == constants.image) {
      /// Image
      return FormImageFieldWidget(
        key: Key(field.key),
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.date) {
      /// Date picker
      return FormDatePickerWidget(
        key: Key(field.key),
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.dateRange) {
      /// Date picker
      return FormDateRangeWidget(
        key: Key(field.key),
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.subform) {
      /// Sub-form
      FrameworkForm form = viewModel.findFormByKey(field.subform);
      return FormSubformFieldWidget(
        key: Key(field.key),
        form: form,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.button) {
      /// Form field button
      return FormButtonFieldWidget(
        key: Key(field.key),
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.singleSelectCheckbox) {
      /// Single select checkbox
      return FormSingleSelectCheckboxFieldWidget(
        key: Key(field.key),
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.radio) {
      /// Radio
      return FormRadioButtonFieldWidget(
        key: Key(field.key),
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.dataList) {
      /// Data list widget
      return FormDataListWidget(
        key: Key(field.key),
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.column) {
      /// Column widget
      return FormColumnFieldWidget(
        key: Key(field.key),
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.row) {
      /// Row widget
      return FormRowFieldWidget(
        key: Key(field.key),
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.separator) {
      /// Separator widget
      return FormSeparatorFieldWidget(
        key: Key(field.key),
        field: field,
      );
    } else if (field.uiType == constants.tabs) {
      /// Tabs widget
      return FormTabsFieldWidget(
        key: Key(field.key),
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.geotag) {
      /// Geotag widget
      return FormGeotagFieldWidget(
        key: Key(field.key),
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.timeline) {
      /// Timeline widget
      return FormTimelineFieldWidget(
        key: Key(field.key),
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.previewGroup) {
      /// Preview Group
      FrameworkForm form = viewModel.findFormByKey(field.subform);
      return FormPreviewGroupFieldWidget(
        key: Key(field.key),
        form: form,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.text) {
      /// Text widget
      return FormTextFieldWidget(
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.scanner) {
      /// Scanner
      return FormScannerFieldWidget(
        key: Key(field.key),
        field: field,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.timePreview) {
      /// Time preview widget
      return FormTimePreviewFieldWidget(
        field: field,
        fieldKey: field.key,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.imageUploader) {
      /// Show Image widget
      return FormImageUploaderWidget(
        field: field,
        fieldKey: field.key,
        viewModel: viewModel,
      );
    } else if (field.uiType == constants.filePicker) {
      return FormFilePickerWidget(
        field: field,
        viewModel: viewModel,
      );
    } else {
      /// Render an empty container of zero dimensions if the UI Type does not
      /// match any predefined types
      return const SizedBox();
    }
  }
}
