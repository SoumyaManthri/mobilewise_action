class NotificationCountRequestParams {
  String username;

  NotificationCountRequestParams({
    required this.username,
  });

  factory NotificationCountRequestParams.fromJson(Map<String, dynamic> json) {
    return NotificationCountRequestParams(
      username: json['userName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'userName': username,
  };
}
