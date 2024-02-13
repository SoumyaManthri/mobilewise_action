class EventRequestModel {
  String eventId;
  String timeStamp;

  EventRequestModel({
    required this.eventId,
    required this.timeStamp,
  });

  factory EventRequestModel.fromJson(Map<String, dynamic> json) {
    return EventRequestModel(
      eventId: json['eventId'] ?? '',
      timeStamp: json['timeStamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'timeStamp': timeStamp,
  };
}