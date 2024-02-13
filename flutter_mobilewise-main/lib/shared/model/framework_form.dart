class FrameworkForms {
  final String initialFormKey;
  final List<FrameworkForm> forms;

  const FrameworkForms({
    required this.initialFormKey,
    required this.forms,
  });

  factory FrameworkForms.fromJson(Map<String, dynamic> json) {
    List<FrameworkForm> forms = <FrameworkForm>[];
    if (json['forms'] != null) {
      json['forms'].forEach((v) {
        forms.add(FrameworkForm.fromJson(v));
      });
    }
    return FrameworkForms(
      initialFormKey: json['initialFormKey'] ?? '',
      forms: forms,
    );
  }

  Map<String, dynamic> toJson() => {
        'initialFormKey': initialFormKey,
        'forms': forms,
      };
}

class FrameworkForm {
  final String formKey;
  final String formName;
  final String entityKey;
  final String parentEntityKey;
  String formType;
  final List<FrameworkFormField> fields;
  final List<FrameworkFormButton> buttons;
  final List<FrameworkFormField> navBar;
  final List<FrameworkFormField> menuDrawer;

  FrameworkForm(
      {required this.formKey,
      required this.formName,
      required this.entityKey,
      required this.parentEntityKey,
      required this.formType,
      required this.fields,
      required this.buttons,
      required this.navBar,
      required this.menuDrawer});

  factory FrameworkForm.fromJson(Map<String, dynamic> json) {
    List<FrameworkFormField> fields = <FrameworkFormField>[];
    if (json['fields'] != null) {
      json['fields'].forEach((v) {
        fields.add(FrameworkFormField.fromJson(v));
      });
    }
    List<FrameworkFormButton> buttons = <FrameworkFormButton>[];
    if (json['buttons'] != null) {
      json['buttons'].forEach((v) {
        buttons.add(FrameworkFormButton.fromJson(v));
      });
    }
    List<FrameworkFormField> navBar = <FrameworkFormField>[];
    if (json['nav_bar'] != null) {
      json['nav_bar'].forEach((v) {
        navBar.add(FrameworkFormField.fromJson(v));
      });
    }
    List<FrameworkFormField> menuDrawer = <FrameworkFormField>[];
    if (json['menu_bar'] != null) {
      json['menu_bar'].forEach((v) {
        menuDrawer.add(FrameworkFormField.fromJson(v));
      });
    }
    return FrameworkForm(
      formKey: json['formKey'] ?? '',
      formName: json['formName'] ?? '',
      entityKey: json['entityKey'] ?? '',
      parentEntityKey: json['parentEntityKey'] ?? '',
      formType: json['formType'] ?? '',
      fields: fields,
      buttons: buttons,
      navBar: navBar,
      menuDrawer: menuDrawer,
    );
  }

  Map<String, dynamic> toJson() => {
        'formKey': formKey,
        'formName': formName,
        'entityKey': entityKey,
        'parentEntityKey': parentEntityKey,
        'formType': formType,
        'fields': fields,
        'buttons': buttons,
        'nav_bar': navBar,
        'menu_bar': menuDrawer,
      };
}

class FrameworkFormField {
  final String key;
  final String label;
  final String uiType;
  final String datatype;
  final int type;
  final String matUiType;
  final String defaultValue;
  final bool isMandatory;
  final bool allowCustomEntry;
  final List<FrameworkFormFieldValue> values;
  final FrameworkFormFieldValuesFromApi valuesApi;
  final List<FrameworkValidation> validations;
  final String hint;
  final String subform;
  final String dataListItemSubform;
  final String dataListClickSubform;
  final String dataListFilterSubform;
  final String icon;
  final int textSize;
  final String textStyle;
  final Map<String, dynamic> textColor;
  final String orientation;
  final int flex;
  final bool isEditable;
  final FilterBy filterBy;
  final DecisionNode decisionNode;
  final int? max;
  final RegExpression regex;
  final String timelineHistoryKey;
  final String numericFieldChange;
  final String image;
  final String entityId;
  final FrameworkFormStyle? style;

  const FrameworkFormField({
    required this.key,
    required this.label,
    required this.uiType,
    required this.datatype,
    required this.type,
    required this.matUiType,
    required this.defaultValue,
    required this.isMandatory,
    required this.allowCustomEntry,
    required this.values,
    required this.valuesApi,
    required this.validations,
    required this.hint,
    required this.subform,
    required this.dataListItemSubform,
    required this.dataListClickSubform,
    required this.dataListFilterSubform,
    required this.icon,
    required this.textSize,
    required this.textStyle,
    required this.textColor,
    required this.orientation,
    required this.flex,
    required this.isEditable,
    required this.filterBy,
    required this.decisionNode,
    required this.max,
    required this.regex,
    required this.timelineHistoryKey,
    required this.numericFieldChange,
    required this.image,
    required this.entityId,
    required this.style,
  });

  factory FrameworkFormField.fromJson(Map<String, dynamic> json) {
    List<FrameworkFormFieldValue> values = <FrameworkFormFieldValue>[];
    if (json['values'] != null) {
      json['values'].forEach((v) {
        values.add(FrameworkFormFieldValue.fromJson(v));
      });
    }

    List<FrameworkValidation> validations = <FrameworkValidation>[];
    if (json['validations'] != null) {
      json['validations'].forEach((v) {
        validations.add(FrameworkValidation.fromJson(v));
      });
    }
    FrameworkFormFieldValuesFromApi valuesFromApi =
        const FrameworkFormFieldValuesFromApi(
            url: '',
            type: '',
            isPreview: false,
            params: [],
            headers: [],
            responseParameter: ResponseParameter(
              label: '',
            ),
            requestKeys: [],
            values: []);
    if (json['values_api'] != null) {
      valuesFromApi =
          FrameworkFormFieldValuesFromApi.fromJson(json['values_api']);
    }
    FilterBy filterBy = const FilterBy(
      sources: [],
      populateBySelection: {},
    );
    if (json['filter_by'] != null) {
      filterBy = FilterBy.fromJson(json['filter_by']);
    }
    DecisionNode decisionNode = const DecisionNode(
      sources: [],
      conditions: {},
    );
    if (json['decision_node'] != null) {
      decisionNode = DecisionNode.fromJson(json['decision_node']);
    }
    RegExpression regExpression = const RegExpression(
      expression: '',
      message: '',
    );
    if (json['regex'] != null) {
      regExpression = RegExpression.fromJson(json['regex']);
    }

    FrameworkFormStyle? style = null;
    if (json['field_style'] != null) {
      style = FrameworkFormStyle.fromJson(json['field_style']);
    }

    return FrameworkFormField(
        key: json['key'] ?? '',
        label: json['label'] ?? '',
        uiType: json['uitype'] ?? '',
        datatype: json['datatype'] ?? '',
        type: json['type'] ?? 1,
        matUiType: json['matUiType'] ?? '',
        defaultValue: json['default'] ?? '',
        isMandatory: json['mandatory'] ?? false,
        allowCustomEntry: json['allow_custom_entry'] ?? false,
        values: values,
        valuesApi: valuesFromApi,
        validations: validations,
        hint: json['placeholderText'] ?? '',
        subform: json['subform'] ?? '',
        dataListItemSubform: json['data_list_item_subform'] ?? '',
        dataListClickSubform: json['data_list_click_subform'] ?? '',
        dataListFilterSubform: json['data_list_filter_subform'] ?? '',
        icon: json['icon'] ?? '',
        textSize: json['text_size'] ?? 16,
        textStyle: json['text_style'] ?? '',
        textColor: json['text_color'] ?? {'default': '000000'},
        orientation: json['orientation'] ?? '',
        flex: json['flex'] ?? 1,
        isEditable: json['editable'] ?? true,
        filterBy: filterBy,
        decisionNode: decisionNode,
        max: json['max'],
        regex: regExpression,
        timelineHistoryKey: json['timeline_history_key'] ?? '',
        numericFieldChange: json['numericFieldChange'] ?? "1.0",
        image: json['image'] ?? "",
        entityId: json['entity_id'] ?? "",
        style: style);
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'uitype': uiType,
        'type': type,
        'datatype': datatype,
        'matUiType': matUiType,
        'default': defaultValue,
        'mandatory': isMandatory,
        'values': values,
        'values_api': valuesApi,
        'placeholderText': hint,
        'subform': subform,
        'data_list_item_subform': dataListItemSubform,
        'data_list_click_subform': dataListClickSubform,
        'data_list_filter_subform': dataListFilterSubform,
        'icon': icon,
        'text_size': textSize,
        'text_style': textStyle,
        'text_color': textColor,
        'orientation': orientation,
        'flex': flex,
        'editable': isEditable,
        'filter_by': filterBy,
        'decision_node': decisionNode,
        'max': max,
        'regex': regex,
        'timeline_history_key': timelineHistoryKey,
        'numericFieldChange': numericFieldChange,
        'field_style': style,
        'entity_id': entityId,
      };
}

class FilterBy {
  final List<String> sources;
  final Map<String, dynamic> populateBySelection;

  const FilterBy({
    required this.sources,
    required this.populateBySelection,
  });

  factory FilterBy.fromJson(Map<String, dynamic> json) {
    List<String> sources = <String>[];
    if (json['source'] != null) {
      sources = (json['source'] as List<dynamic>).cast<String>();
    }
    return FilterBy(
      sources: sources,
      populateBySelection: json['populate_by_selection'],
    );
  }

  Map<String, dynamic> toJson() => {
        'source': sources,
        'populate_by_selection': populateBySelection,
      };
}

class FrameworkFormButton {
  final String key;
  final String label;
  final String uiType;
  final int type;
  final DecisionNode decisionNode;
  final List<PreSubmissionField> preSubmissionFields;

  const FrameworkFormButton({
    required this.key,
    required this.label,
    required this.uiType,
    required this.type,
    required this.decisionNode,
    required this.preSubmissionFields,
  });

  factory FrameworkFormButton.fromJson(Map<String, dynamic> json) {
    DecisionNode decisionNode = const DecisionNode(
      sources: [],
      conditions: {},
    );
    if (json['decision_node'] != null) {
      decisionNode = DecisionNode.fromJson(json['decision_node']);
    }
    List<PreSubmissionField> preSubmissionFields = <PreSubmissionField>[];
    if (json['pre_submission_fields'] != null) {
      json['pre_submission_fields'].forEach((v) {
        preSubmissionFields.add(PreSubmissionField.fromJson(v));
      });
    }
    return FrameworkFormButton(
      key: json['key'] ?? '',
      label: json['label'] ?? '',
      uiType: json['uitype'] ?? '',
      type: json['type'] ?? '',
      decisionNode: decisionNode,
      preSubmissionFields: preSubmissionFields,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'uitype': uiType,
        'type': type,
        'decision_node': decisionNode,
        'pre_submission_fields': preSubmissionFields,
      };
}

class PreSubmissionField {
  final String key;
  final String entity;
  final String value;

  const PreSubmissionField({
    required this.key,
    required this.entity,
    required this.value,
  });

  factory PreSubmissionField.fromJson(Map<String, dynamic> json) {
    return PreSubmissionField(
      key: json['key'] ?? '',
      entity: json['entity'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'entity': entity,
        'value': value,
      };
}

class DecisionNode {
  final List<String> sources;
  final Map<String, dynamic> conditions;

  const DecisionNode({
    required this.sources,
    required this.conditions,
  });

  factory DecisionNode.fromJson(Map<String, dynamic> json) {
    List<String> sources = <String>[];
    if (json['source'] != null) {
      sources = (json['source'] as List<dynamic>).cast<String>();
    }
    return DecisionNode(
      sources: sources,
      conditions: json['conditions'],
    );
  }

  Map<String, dynamic> toJson() => {
        'source': sources,
        'conditions': conditions,
      };
}

class FrameworkFormFieldValue {
  final String value;
  final bool isSelected;
  final DecisionNode decisionNode;

  const FrameworkFormFieldValue({
    required this.value,
    required this.isSelected,
    required this.decisionNode,
  });

  factory FrameworkFormFieldValue.fromJson(Map<String, dynamic> json) {
    DecisionNode decisionNode = const DecisionNode(
      sources: [],
      conditions: {},
    );
    if (json['decision_node'] != null) {
      decisionNode = DecisionNode.fromJson(json['decision_node']);
    }

    String val;
    if (json['value'] != null && json['value'] is! String) {
      val = json['value'].toString();
    } else {
      val = json['value'];
    }

    return FrameworkFormFieldValue(
      value: val ?? '',
      isSelected: json['isSelected'] ?? true,
      decisionNode: decisionNode,
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'isSelected': isSelected,
        'decision_node': decisionNode,
      };
}

class FrameworkFormFieldValuesFromApi {
  final String url;
  final String type;
  final List<String> params;
  final List<ApiHeader> headers;
  final ResponseParameter responseParameter;
  final List<RequestKey> requestKeys;
  final List<FrameworkFormFieldValue> values;
  final bool isPreview;

  const FrameworkFormFieldValuesFromApi({
    required this.url,
    required this.type,
    required this.params,
    required this.headers,
    required this.responseParameter,
    required this.requestKeys,
    required this.values,
    required this.isPreview,
  });

  factory FrameworkFormFieldValuesFromApi.fromJson(Map<String, dynamic> json) {
    List<FrameworkFormFieldValue> values = <FrameworkFormFieldValue>[];
    if (json['values'] != null) {
      json['values'].forEach((v) {
        values.add(FrameworkFormFieldValue.fromJson(v));
      });
    }
    List<ApiHeader> headers = <ApiHeader>[];
    if (json['headers'] != null) {
      json['headers'].forEach((v) {
        headers.add(ApiHeader.fromJson(v));
      });
    }
    List<RequestKey> requestKeys = <RequestKey>[];
    if (json['request_key'] != null) {
      json['request_key'].forEach((v) {
        requestKeys.add(RequestKey.fromJson(v));
      });
    }
    List<String> params = <String>[];
    if (json['params'] != null) {
      params = (json['params'] as List<dynamic>).cast<String>();
    }

    ResponseParameter response = const ResponseParameter(
      label: '',
    );
    if (json['response-parameter'] != null) {
      response = ResponseParameter.fromJson(json['response-parameter']);
    }

    return FrameworkFormFieldValuesFromApi(
      url: json['datasource'] ?? '',
      type: json['method'] ?? '',
      isPreview: json['preview'] ?? false,
      params: params,
      headers: headers,
      responseParameter: response,
      requestKeys: requestKeys,
      values: values,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'type': type,
        'preview': isPreview,
        'params': params,
        'headers': headers,
        'response-parameter': responseParameter,
        'request_key': requestKeys,
        'values': values,
      };
}

class ResponseParameter {
  final String label;

  const ResponseParameter({
    required this.label,
  });

  factory ResponseParameter.fromJson(Map<String, dynamic> json) {
    return ResponseParameter(
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
      };
}

class ApiHeader {
  final String key;
  final String value;

  const ApiHeader({
    required this.key,
    required this.value,
  });

  factory ApiHeader.fromJson(Map<String, dynamic> json) {
    return ApiHeader(
      key: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
      };
}

class RequestKey {
  final String formKey;
  final String key;

  const RequestKey({
    required this.formKey,
    required this.key,
  });

  factory RequestKey.fromJson(Map<String, dynamic> json) {
    return RequestKey(
      formKey: json['form_key'] ?? '',
      key: json['key'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'form_key': formKey,
        'key': key,
      };
}

class RegExpression {
  final String expression;
  final String message;

  const RegExpression({
    required this.expression,
    required this.message,
  });

  factory RegExpression.fromJson(Map<String, dynamic> json) {
    return RegExpression(
      expression: json['exp'] ?? '',
      message: json['msg'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'exp': expression,
        'msg': message,
      };
}

class FrameworkFormStyle {
  final String bgColor;
  final String color;
  final int size;
  final bool bold;
  final bool italics;
  final bool underline;
  final int marginTop;
  final String textAlign;

  FrameworkFormStyle(
      {required this.bgColor,
      required this.color,
      required this.size,
      required this.bold,
      required this.italics,
      required this.underline,
      required this.marginTop,
      required this.textAlign});

  factory FrameworkFormStyle.fromJson(Map<String, dynamic> json) {
    return FrameworkFormStyle(
      bgColor: json['bg_color'] ?? '',
      color: json['color'] ?? '',
      size: json['size'] ?? 15,
      bold: json['bold'] ?? false,
      italics: json['italics'] ?? false,
      underline: json['underline'] ?? false,
      marginTop: json['margin-top'] ?? 0,
      textAlign: json['text-align'] ?? 'left',
    );
  }

  Map<String, dynamic> toJson() => {
        'bg_color': bgColor,
        'color': color,
        'size': size,
        'bold': bold,
        'italics': italics,
        'underline': underline,
        'margin-top': marginTop,
        'text-align': textAlign,
      };
}

class FrameworkValidation {
  String? errorMessage;
  String? validationType;
  String? validationValue;

  FrameworkValidation(
      {this.errorMessage, this.validationType, this.validationValue});

  FrameworkValidation.fromJson(Map<String, dynamic> json) {
    errorMessage = json['error_message'];
    validationType = json['validation_type'];
    validationValue = json['validation_value'];
  }

  Map<String, dynamic> toJson() => {
        'error_message': errorMessage,
        'validation_type': validationType,
        'validation_value': validationValue,
      };
}
