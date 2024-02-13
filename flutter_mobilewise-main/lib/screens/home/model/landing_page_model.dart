class LandingPageModel {
  final String key;
  final String name;
  final List<LandingPageButton> buttons;

  const LandingPageModel({
    this.key = '',
    this.name = '',
    this.buttons = const [],
  });

  factory LandingPageModel.fromJson(Map<String, dynamic> json) {
    List<LandingPageButton> buttons = <LandingPageButton>[];
    if (json['buttons'] != null) {
      json['buttons'].forEach((v) {
        buttons.add(LandingPageButton.fromJson(v));
      });
    }
    return LandingPageModel(
      key: json['screenKey'] ?? '',
      name: json['screenName'] ?? '',
      buttons: buttons,
    );
  }

  Map<String, dynamic> toJson() => {
        'screenKey': key,
        'screenName': name,
        'buttons': buttons,
      };
}

class LandingPageButton {
  final String key;
  final String label;
  final String child;

  const LandingPageButton({
    required this.key,
    required this.label,
    required this.child,
  });

  factory LandingPageButton.fromJson(Map<String, dynamic> json) {
    return LandingPageButton(
      key: json['key'] ?? '',
      label: json['label'] ?? '',
      child: json['child'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'child': child,
      };
}
