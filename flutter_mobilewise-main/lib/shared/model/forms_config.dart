import '../../screens/forms/model/server_form_model.dart';

class FormsConfig {
  final List<ServerFormModel> formList;

  const FormsConfig({
    required this.formList,
  });

  factory FormsConfig.fromJson(Map<String, dynamic> json) {
    List<ServerFormModel> formList = <ServerFormModel>[];
    if (json['forms'] != null) {
      json['forms'].forEach((v) {
        formList.add(ServerFormModel.fromJson(v));
      });
    }
    return FormsConfig(
      formList: formList,
    );
  }

  Map<String, dynamic> toJson() => {
        'forms': formList,
      };
}
