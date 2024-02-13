class FormsConfigRequestParams {
  Map<String, int>? version;
  String appId;

  FormsConfigRequestParams(this.version, this.appId);

  FormsConfigRequestParams.fromJson(Map<String, dynamic> json)
      : version = json['version'],
        appId = json['appId'];

  Map<String, dynamic> toJson() => {
        'version': version,
        'appId': appId,
      };
}
