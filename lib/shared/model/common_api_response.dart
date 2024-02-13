class CommonApiResponse {
  bool? result;
  int? statusCode;
  String? statusCodeDescription;
  String? message;
  Map<String, dynamic>? response;
  String? error;

  CommonApiResponse(
      {this.result,
      this.statusCode,
      this.statusCodeDescription,
      this.message,
      this.response});

  CommonApiResponse.withError(String errorMessage) {
    error = errorMessage;
  }

  CommonApiResponse.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    statusCode = json['statusCode'];
    statusCodeDescription = json['statusCodeDescription'];
    message = json['message'];
    response = json['response'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data['result'] = result;
    data['statusCode'] = statusCode;
    data['statusCodeDescription'] = statusCodeDescription;
    data['message'] = message;
    data['response'] = response;
    return data;
  }
}
