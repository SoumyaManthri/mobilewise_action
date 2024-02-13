import '../screens/forms/view_model/form_view_model.dart';
import '../shared/model/framework_form.dart';
import '../utils/app_state.dart';
import '../utils/common_constants.dart' as constants;

class ValidationUtil {
  static ValidationUtil? _instance;

  ValidationUtil._();

  static ValidationUtil get instance => _instance ??= ValidationUtil._();

  bool isEmailValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  /// This is the first version of validations (Just mandatory validations)
  /// To store the validation error field label and the error message
  Map<String, String> errorFieldMap = {};

  Map<String, String> validateForm(
      FormViewModel viewModel, FrameworkForm form) {
    for (FrameworkFormField field in form.fields) {
      String validationErrorMsg = " ";
      if (!field.isMandatory && field.uiType == constants.dropdown) {
        /// If the dropdown is not mandatory
        String? value = AppState.instance.formTempMap[field.key];
        if (value != null && value.isNotEmpty) {
          if (!field.allowCustomEntry &&
              !isValidItem(field, value, viewModel)) {
            validationErrorMsg =
                'Please select a valid value for ${field.label}';
            errorFieldMap[field.key] = validationErrorMsg;
          }
        }

        /// Dropdown could have a subform linked to it, based
        /// on value selection
        FrameworkForm subform = FormViewModel.emptyFormData();

        if (field.values.isNotEmpty) {
          for (FrameworkFormFieldValue v in field.values) {
            if (v.value == value) {
              if (v.decisionNode.conditions.isNotEmpty) {
                subform = viewModel.findFormByKey(v.decisionNode
                    .conditions[constants.defaultKey][constants.subform]);
                break;
              }
            }
          }
        } else if (field.valuesApi.values.isNotEmpty) {
          for (FrameworkFormFieldValue v in field.valuesApi.values) {
            if (v.value == value) {
              if (v.decisionNode.conditions.isNotEmpty) {
                subform = viewModel.findFormByKey(v.decisionNode
                    .conditions[constants.defaultKey][constants.subform]);
                break;
              }
            }
          }
        }

        if (subform.formKey.isNotEmpty) {
          /// Valid subform exists for this selection
          validateForm(viewModel, subform);
        }
      } else if (field.uiType == constants.edittext) {
        String? value = AppState.instance.formTempMap[field.key];
        if(field.isMandatory && (value == null || value.isEmpty)){
          validationErrorMsg = 'Please enter ${field.label}';
          errorFieldMap[field.key] = validationErrorMsg;
        }
      } else if (field.isMandatory && field.uiType != constants.subform) {
        if (AppState.instance.formTempMap.containsKey(field.key)) {
          /// 1. Check for the values in the tempMap based on UI Type
          /// 2. No need to check for date, as DateTime can never be empty
          /// or null (containsKey check is enough)
          if (field.uiType == constants.dropdown) {
            String value = AppState.instance.formTempMap[field.key];
            if (value.isEmpty) {
              validationErrorMsg = '${field.label} is a mandatory field';
              errorFieldMap[field.key] = validationErrorMsg;
            }

            if (!field.allowCustomEntry &&
                !isValidItem(field, value, viewModel)) {
              validationErrorMsg =
                  'Please select a valid value for ${field.label}';
              errorFieldMap[field.key] = validationErrorMsg;
            }

            /// Dropdown could have a subform linked to it, based
            /// on value selection
            FrameworkForm subform = FormViewModel.emptyFormData();

            if (field.values.isNotEmpty) {
              for (FrameworkFormFieldValue v in field.values) {
                if (v.value == value) {
                  if (v.decisionNode.conditions.isNotEmpty) {
                    subform = viewModel.findFormByKey(v.decisionNode
                        .conditions[constants.defaultKey][constants.subform]);
                    break;
                  }
                }
              }
            } else if (field.valuesApi.values.isNotEmpty) {
              for (FrameworkFormFieldValue v in field.valuesApi.values) {
                if (v.value == value) {
                  if (v.decisionNode.conditions.isNotEmpty) {
                    subform = viewModel.findFormByKey(v.decisionNode
                        .conditions[constants.defaultKey][constants.subform]);
                    break;
                  }
                }
              }
            }

            if (subform.formKey.isNotEmpty) {
              /// Valid subform exists for this selection
              validateForm(viewModel, subform);
            }
          } else if (field.uiType == constants.edittext) {
            /// Edittext fields have string values
            String value = AppState.instance.formTempMap[field.key];

            if (value.isEmpty) {
              validationErrorMsg = '${field.label} is a mandatory field';
              errorFieldMap[field.key] = validationErrorMsg;
            } else if (value.trim() == '') {
              validationErrorMsg = 'Invalid entry for ${field.label}';
              errorFieldMap[field.key] = validationErrorMsg;
            } else if (field.regex.expression.isNotEmpty) {
              /// Perform regular expression check
              var re = RegExp(field.regex.expression);
              if (!re.hasMatch(value)) {
                validationErrorMsg = field.regex.message;
                errorFieldMap[field.key] = validationErrorMsg;
              }
            }
          } else if (field.uiType == constants.address) {
            /// Address fields have string values
            String value = AppState.instance.formTempMap[field.key];

            if (value.isEmpty) {
              validationErrorMsg = '${field.label} is a mandatory field';
              errorFieldMap[field.key] = validationErrorMsg;
            } else if (value.trim() == '') {
              validationErrorMsg = 'Invalid entry for ${field.label}';
              errorFieldMap[field.key] = validationErrorMsg;
            }
          } else if (field.uiType == constants.numericEdittext) {
            /// Numeric Edittext fields have string values
            String value = AppState.instance.formTempMap[field.key];

            if (value.isEmpty) {
              validationErrorMsg = '${field.label} is a mandatory field';
              errorFieldMap[field.key] = validationErrorMsg;
            } else if (value.trim() == '') {
              validationErrorMsg = 'Invalid entry for ${field.label}';
              errorFieldMap[field.key] = validationErrorMsg;
            } else if (field.regex.expression.isNotEmpty) {
              /// Perform regular expression check
              var re = RegExp(field.regex.expression);
              if (!re.hasMatch(value)) {
                validationErrorMsg = field.regex.message;
                errorFieldMap[field.key] = validationErrorMsg;
              }
            }
          } else if (field.uiType == constants.dateRange) {
            /// DateRange fields have string values
            String value = AppState.instance.formTempMap[field.key];
            if (value.isEmpty) {
              validationErrorMsg = '${field.label} is a mandatory field';
              errorFieldMap[field.key] = validationErrorMsg;
            }
          } else if (field.uiType == constants.image) {
            /// Image field has List<XFile?> value
            List<dynamic> images = AppState.instance.formTempMap[field.key];
            if (images.isEmpty) {
              validationErrorMsg = '${field.label} is a mandatory field';
              errorFieldMap[field.key] = validationErrorMsg;
            }
          } else if (field.uiType == constants.scanner) {
            /// Scanner fields have string values
            String value = AppState.instance.formTempMap[field.key];

            if (value.isEmpty) {
              validationErrorMsg = '${field.label} is a mandatory field';
              errorFieldMap[field.key] = validationErrorMsg;
            } else if (value.trim() == '') {
              validationErrorMsg = 'Invalid entry for ${field.label}';
              errorFieldMap[field.key] = validationErrorMsg;
            }
          } else if (field.uiType == constants.radio ||
              field.uiType == constants.singleSelectCheckbox) {
            /// Radio and checkbox fields have string values
            String value = AppState.instance.formTempMap[field.key];
            if (value.isEmpty) {
              validationErrorMsg = '${field.label} is a mandatory field';
              errorFieldMap[field.key] = validationErrorMsg;
            }

            /// Radio or checkbox could have a subform linked to it, based
            /// on value selection
            FrameworkForm subform = FormViewModel.emptyFormData();
            for (FrameworkFormFieldValue v in field.values) {
              if (v.value == value) {
                if (v.decisionNode.conditions.isNotEmpty) {
                  subform = viewModel.findFormByKey(v.decisionNode
                      .conditions[constants.defaultKey][constants.subform]);
                  break;
                }
              }
            }
            if (subform.formKey.isNotEmpty) {
              /// Valid subform exists for this selection
              validateForm(viewModel, subform);
            }
          }
        } else if (viewModel.clickedSubmissionValuesMap
            .containsKey(field.key)) {
          /// If the values are present in the submitted values map
          if (field.uiType == constants.dropdown) {
            String value = viewModel.clickedSubmissionValuesMap[field.key];
            if (value.isEmpty) {
              validationErrorMsg = '${field.label} is a mandatory field';
              errorFieldMap[field.key] = validationErrorMsg;
            }

            if (!field.allowCustomEntry &&
                !isValidItem(field, value, viewModel)) {
              validationErrorMsg =
                  'Please select a valid value for ${field.label}';
              errorFieldMap[field.key] = validationErrorMsg;
            }
          } else if (field.uiType == constants.edittext ||
              field.uiType == constants.dateRange) {
            /// Dropdown and edittext fields have string values
            String value = viewModel.clickedSubmissionValuesMap[field.key];
            if (value.isEmpty) {
              validationErrorMsg = '${field.label} is a mandatory field';
              errorFieldMap[field.key] = validationErrorMsg;
            }
          } else if (field.uiType == constants.image) {
            /// Image field has List<XFile?> value
            List<dynamic> images =
                viewModel.clickedSubmissionValuesMap[field.key];
            if (images.isEmpty) {
              validationErrorMsg = '${field.label} is a mandatory field';
              errorFieldMap[field.key] = validationErrorMsg;
            }
          } else if (field.uiType == constants.radio ||
              field.uiType == constants.singleSelectCheckbox) {
            /// Radio and checkbox fields have string values
            String value = viewModel.clickedSubmissionValuesMap[field.key];
            if (value.isEmpty) {
              validationErrorMsg = '${field.label} is a mandatory field';
              errorFieldMap[field.key] = validationErrorMsg;
            }

            /// Radio or checkbox could have a subform linked to it, based
            /// on value selection
            FrameworkForm subform = FormViewModel.emptyFormData();
            for (FrameworkFormFieldValue v in field.values) {
              if (v.value == value) {
                if (v.decisionNode.conditions.isNotEmpty) {
                  subform = viewModel.findFormByKey(v.decisionNode
                      .conditions[constants.defaultKey][constants.subform]);
                  break;
                }
              }
            }
            if (subform.formKey.isNotEmpty) {
              /// Valid subform exists for this selection
              validateForm(viewModel, subform);
            }
          }
        } else {
          /// Value is not present in the tempMap. Validation failed!
          validationErrorMsg = '${field.label} is a mandatory field';
          errorFieldMap[field.key] = validationErrorMsg;
        }
      } else if (field.uiType == constants.subform) {
        /// If the field is a subform field, recursively calling this method to
        /// validate the subform
        FrameworkForm subForm = viewModel.findFormByKey(field.subform);
        if (subForm.formKey.isNotEmpty) {
          validateForm(viewModel, subForm);
        }
      }
    }

    return errorFieldMap;
  }

  _getCountOfMandatoryFieldsForAddItemWidget(List<FrameworkFormField> fields) {
    int count = 0;
    for (FrameworkFormField f in fields) {
      if (f.isMandatory) {
        count++;
      }
    }
    return count;
  }

  /// This method is called when a dropdown does not allow custom values to
  /// be entered
  /// If the value entered by the user is not present in the allowed values
  /// for a dropdown, false is returned and the user is shown a snackBar message
  /// stating that the value entered is invalid
  static bool isValidItem(
      FrameworkFormField field, String selectedValue, FormViewModel viewModel) {
    if (field.allowCustomEntry && selectedValue.isNotEmpty) {
      return true;
    } else if (viewModel.dropdownValues.containsKey(field.key)) {
      List<String>? values = viewModel.dropdownValues[field.key];
      if (values != null && values.isNotEmpty) {
        for (String value in values) {
          if (selectedValue == value) {
            return true;
          }
        }
      }
    }
    return false;
  }

  static bool isValidItemUsingKey(
      String key, String selectedValue, FormViewModel viewModel) {
    if (viewModel.dropdownValues.containsKey(key)) {
      List<String>? values = viewModel.dropdownValues[key];
      if (values != null && values.isNotEmpty) {
        for (String value in values) {
          if (selectedValue == value) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
