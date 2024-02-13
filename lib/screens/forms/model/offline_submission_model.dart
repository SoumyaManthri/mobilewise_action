import 'package:hive/hive.dart';

import '../../../screens/forms/model/entity_instance_model.dart';
import '../../../utils/common_constants.dart' as constants;

part 'offline_submission_model.g.dart';

/// This is a model class for a Hive box.
/// DO NOT CHANGE THE 'HiveType' or the 'HiveField'(s) for this class

@HiveType(typeId: constants.submissionsTypeAdapterId)
class OfflineSubmissionModel {
  @HiveField(0)
  final String submissionId;
  @HiveField(1)
  final int serverSyncTs;
  @HiveField(2)
  final List<EntityInstance> entities;
  @HiveField(3)
  int retries;
  @HiveField(4)
  String buttonKey;

  OfflineSubmissionModel(this.submissionId, this.serverSyncTs,
      this.entities, this.retries, this.buttonKey);
}
