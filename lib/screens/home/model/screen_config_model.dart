import 'package:hive/hive.dart';

import '../../../utils/common_constants.dart' as constants;

part 'screen_config_model.g.dart';

/// This is a model class for a Hive box.
/// DO NOT CHANGE THE 'HiveType' or the 'HiveField'(s) for this class

@HiveType(typeId: constants.screenConfigTypeAdapterId)
class ScreensConfigModel {
  @HiveField(0)
  final int version;
  @HiveField(1)
  final String screensJsonString;

  const ScreensConfigModel({
    this.version = 0,
    this.screensJsonString = '',
  });

  factory ScreensConfigModel.fromJson(Map<String, dynamic> json) {
    return ScreensConfigModel(
      version: json['version'] ?? 0,
      screensJsonString: json['formJson'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'formJson': screensJsonString,
  };
}
