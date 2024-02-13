class SubmittedDataModel {
  bool? status;
  int? statuscode;
  String? message;
  List<Submissions>? submissions;
  String? error;

  SubmittedDataModel(
      {this.status, this.statuscode, this.message, this.submissions});


  SubmittedDataModel.withError(String errorMessage) {
    error = errorMessage;
  }

  SubmittedDataModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statuscode = json['statuscode'];
    message = json['message'];
    if (json['submissions'] != null) {
      submissions = <Submissions>[];
      json['submissions'].forEach((v) {
        submissions!.add(Submissions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['statuscode'] = statuscode;
    data['message'] = message;
    if (submissions != null) {
      data['submissions'] = submissions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Submissions {
  String? submissionId;
  List<EntityValuesJson>? entityValuesJson;
  String? createdDate;
  String? entityId;
  String? entityName;
  List<ChildEntities>? childEntities;
  Map<String, EntityValuesJson>? dataMap;

  Submissions(
      {this.submissionId,
      this.entityValuesJson,
      this.createdDate,
      this.entityId,
      this.entityName,
      this.childEntities});

  Submissions.fromJson(Map<String, dynamic> json) {
    submissionId = json['submission_id'];
    if (json['entity_values_json'] != null) {
      entityValuesJson = <EntityValuesJson>[];
      json['entity_values_json'].forEach((v) {
        entityValuesJson!.add(EntityValuesJson.fromJson(v));
      });
    }
    createdDate = json['created_date'];
    entityId = json['entity_id'];
    entityName = json['entity_name'];
    if (json['child_entities'] != null) {
      childEntities = <ChildEntities>[];
      json['child_entities'].forEach((v) {
        childEntities!.add(ChildEntities.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['submission_id'] = submissionId;
    if (entityValuesJson != null) {
      data['entity_values_json'] =
          entityValuesJson!.map((v) => v.toJson()).toList();
    }
    data['created_date'] = createdDate;
    data['entity_id'] = entityId;
    data['entity_name'] = entityName;
    if (childEntities != null) {
      data['child_entities'] = childEntities!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EntityValuesJson {
  String? value;
  String? widgetId;
  String? widgetLabel;
  String? widgetType;

  EntityValuesJson(
      {this.value, this.widgetId, this.widgetLabel, this.widgetType});

  EntityValuesJson.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    widgetId = json['widget_id'];
    widgetLabel = json['widget_label'];
    widgetType = json['widget_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['widget_id'] = widgetId;
    data['widget_label'] = widgetLabel;
    data['widget_type'] = widgetType;
    return data;
  }
}

class ChildEntities {
  String? submissionId;
  List<EntityValuesJson>? entityValuesJson;
  String? createdDate;
  String? entityId;
  String? entityName;

  ChildEntities(
      {this.submissionId,
      this.entityValuesJson,
      this.createdDate,
      this.entityId,
      this.entityName});

  ChildEntities.fromJson(Map<String, dynamic> json) {
    submissionId = json['submission_id'];
    if (json['entity_values_json'] != null) {
      entityValuesJson = <EntityValuesJson>[];
      json['entity_values_json'].forEach((v) {
        entityValuesJson!.add(EntityValuesJson.fromJson(v));
      });
    }
    createdDate = json['created_date'];
    entityId = json['entity_id'];
    entityName = json['entity_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['submission_id'] = submissionId;
    if (entityValuesJson != null) {
      data['entity_values_json'] =
          entityValuesJson!.map((v) => v.toJson()).toList();
    }
    data['created_date'] = createdDate;
    data['entity_id'] = entityId;
    data['entity_name'] = entityName;
    return data;
  }
}
