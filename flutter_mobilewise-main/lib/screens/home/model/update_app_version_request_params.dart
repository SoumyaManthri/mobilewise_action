class UpdateAppVersionRequestParams {
  String username;
  String version;
  String appId;

  UpdateAppVersionRequestParams(
    this.username,
    this.version,
    this.appId,
  );

  UpdateAppVersionRequestParams.fromJson(Map<String, dynamic> json)
      : username = json['userName'],
        version = json['version'],
        appId = json['appId'];

  Map<String, dynamic> toJson() => {
        'userName': username,
        'version': version,
        'appId': appId,
      };
}
