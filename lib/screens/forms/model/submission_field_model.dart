import 'package:hive/hive.dart';

import '../../../utils/common_constants.dart' as constants;

part 'submission_field_model.g.dart';

/// This is a model class for a Hive box.
/// DO NOT CHANGE THE 'HiveType' or the 'HiveField'(s) for this class

@HiveType(typeId: constants.submissionFieldTypeAdapterId)
class SubmissionField {
  @HiveField(0)
  String key;
  @HiveField(1)
  dynamic value;

  SubmissionField({
    required this.key,
    required this.value,
  });

  factory SubmissionField.fromJson(Map<String, dynamic> json) {
    return SubmissionField(
      key: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'value': value,
  };
}