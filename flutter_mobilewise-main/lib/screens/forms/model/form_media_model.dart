import 'package:hive/hive.dart';

import '../../../utils/common_constants.dart' as constants;

part 'form_media_model.g.dart';

/// This is a model class for a Hive box.
/// DO NOT CHANGE THE 'HiveType' or the 'HiveField'(s) for this class

@HiveType(typeId: constants.formMediaTypeAdapterId)
class FormMediaModel {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String path;
  @HiveField(2)
  final int retries;

  FormMediaModel(this.name, this.path, this.retries);
}
