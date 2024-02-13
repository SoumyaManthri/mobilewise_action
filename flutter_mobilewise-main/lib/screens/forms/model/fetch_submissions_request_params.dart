class FetchSubmissionRequestParams {
  String appId;
  String username;
  Map<String, int> eventTimestampMap;

  FetchSubmissionRequestParams({
    required this.appId,
    required this.username,
    required this.eventTimestampMap,
  });

  factory FetchSubmissionRequestParams.fromJson(Map<String, dynamic> json) {
    return FetchSubmissionRequestParams(
      appId: json['appId'] ?? '',
      username: json['userName'] ?? '',
      eventTimestampMap: json['eventTimeStampMap'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'appId': appId,
        'userName': username,
        'eventTimeStampMap': eventTimestampMap,
      };
}
