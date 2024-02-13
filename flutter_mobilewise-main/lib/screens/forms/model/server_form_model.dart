import 'package:hive/hive.dart';

import '../../../utils/common_constants.dart' as constants;

part 'server_form_model.g.dart';

/// This is a model class for a Hive box.
/// DO NOT CHANGE THE 'HiveType' or the 'HiveField'(s) for this class

@HiveType(typeId: constants.serverFormTypeAdapterId)
class ServerFormModel {
  @HiveField(0)
  final int version;
  @HiveField(1)
  final String formJson;
  @HiveField(2)
  final String formKey;
  @HiveField(3)
  final String formType;

  ServerFormModel(this.version, this.formJson, this.formKey, this.formType);

  factory ServerFormModel.fromJson(Map<String, dynamic> json) {
    return ServerFormModel(
      json['version'] ?? 0,
      json['formJson'] ?? '',
      json['formKey'] ?? '',
      json['formType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'formJson': formJson,
    'formKey': formKey,
    'formType' :formType,
  };
}
