class ScreenConfigRequestParams {
  int version;
  String appId;

  ScreenConfigRequestParams(this.version, this.appId);

  ScreenConfigRequestParams.fromJson(Map<String, dynamic> json)
      : version = json['version'],
        appId = json['appId'];

  Map<String, dynamic> toJson() => {
        'version': version,
        'appId': appId,
      };
}
