import 'package:hive/hive.dart';

import '../../../screens/forms/model/submission_field_model.dart';
import '../../../utils/common_constants.dart' as constants;

part 'entity_instance_model.g.dart';

/// This is a model class for a Hive box.
/// DO NOT CHANGE THE 'HiveType' or the 'HiveField'(s) for this class

@HiveType(typeId: constants.entitiesTypeAdapterId)
class EntityInstance {
  @HiveField(0)
  String id;
  @HiveField(1)
  String key;
  @HiveField(2)
  String? parentId;
  @HiveField(3)
  List<String> childIds;
  @HiveField(4)
  List<SubmissionField> submissionField;

  EntityInstance({
    required this.id,
    required this.key,
    required this.parentId,
    required this.childIds,
    required this.submissionField,
  });

  factory EntityInstance.fromJson(Map<String, dynamic> json) {
    List<String> childIds = <String>[];
    if (json['chieldEntityIds'] != null) {
      json['chieldEntityIds'].forEach((v) {
        childIds.add(v);
      });
    }
    List<SubmissionField> fields = <SubmissionField>[];
    if (json['fields'] != null) {
      json['fields'].forEach((v) {
        fields.add(SubmissionField.fromJson(v));
      });
    }
    return EntityInstance(
      id: json['entityId'] ?? -1,
      key: json['entityKey'] ?? '',
      parentId: json['parentEntityId'],
      childIds: childIds,
      submissionField: fields,
    );
  }

  Map<String, dynamic> toJson() => {
        'entityId': id,
        'entityKey': key,
        'parentEntityId': parentId,
        'chieldEntityIds': childIds,
        'fields': submissionField,
      };
}
