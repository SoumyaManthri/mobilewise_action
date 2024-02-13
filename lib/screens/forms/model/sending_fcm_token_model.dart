class SendingFcmTokenModel {
  String token;
  String username;

  SendingFcmTokenModel({
    required this.token,
    required this.username,
  });

  factory SendingFcmTokenModel.fromJson(Map<String, dynamic> json) {
    return SendingFcmTokenModel(
      token: json['token'] ?? '',
      username: json['userName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'userName': username,
      };
}
