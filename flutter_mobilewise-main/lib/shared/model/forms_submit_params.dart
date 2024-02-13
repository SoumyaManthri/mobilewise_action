class FormSubmitParams {
  String entity;
  String key;
  String value;

  FormSubmitParams(this.entity, this.key, this.value);

  FormSubmitParams.fromJson(Map<String, dynamic> json)
      : entity = json['entity'],
        key = json['key'],
        value = json['value'];

  Map<String, dynamic> toJson() => {
        'entity': entity,
        'key': key,
        'value': value,
      };
}
