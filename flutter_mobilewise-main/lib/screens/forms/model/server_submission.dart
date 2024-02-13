import 'package:hive/hive.dart';

import '../../../utils/common_constants.dart' as constants;

part 'server_submission.g.dart';

/// This is a model class for a Hive box.
/// DO NOT CHANGE THE 'HiveType' or the 'HiveField'(s) for this class

@HiveType(typeId: constants.fetchedSubmissionsTypeAdapterId)
class ServerSubmission {
  @HiveField(0)
  int timestamp;
  @HiveField(1)
  String submissionId;
  @HiveField(2)
  List<String> entities;
  @HiveField(3)
  int reportedTs;

  ServerSubmission({
    required this.timestamp,
    required this.submissionId,
    required this.entities,
    required this.reportedTs,
  });

  factory ServerSubmission.fromJson(Map<String, dynamic> json) {
    List<String> entities = <String>[];
    if (json['entities'] != null) {
      json['entities'].forEach((v) {
        entities.add(v);
      });
    }
    return ServerSubmission(
      timestamp: json['timeStamp'] ?? 0,
      submissionId: json['submissionId'] ?? '',
      entities: entities,
      reportedTs: json['reportedTimeStamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'timeStamp': timestamp,
    'submissionId': submissionId,
    'entities': entities,
    'reportedTimeStamp': reportedTs,
  };
}