import '../../../screens/forms/model/entity_instance_model.dart';

class FormSubmissionRequestParams {
  String appId;
  String username;
  String timestamp;
  String submissionId;
  List<EntityInstance> entityInstances;
  String editedEntity;

  FormSubmissionRequestParams(
      {required this.appId,
      required this.username,
      required this.timestamp,
      required this.submissionId,
      required this.entityInstances,
      required this.editedEntity});

  factory FormSubmissionRequestParams.fromJson(Map<String, dynamic> json) {
    List<EntityInstance> entities = <EntityInstance>[];
    if (json['data'] != null) {
      json['data'].forEach((v) {
        entities.add(EntityInstance.fromJson(v));
      });
    }
    return FormSubmissionRequestParams(
        appId: json['appId'] ?? '',
        username: json['userName'] ?? '',
        timestamp: json['timeStamp'] ?? '',
        submissionId: json['submissionId'] ?? '',
        editedEntity: json['editedEntity'] ?? '',
        entityInstances: entities);
  }

  Map<String, dynamic> toJson() => {
        'appId': appId,
        'userName': username,
        'timeStamp': timestamp,
        'submissionId': submissionId,
        'editedEntity': editedEntity,
        'data': entityInstances,
  };
}
