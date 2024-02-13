
class ThemeModel {
    String themeId;
    String themeName;
    String primaryColor;
    String secondaryColor;
    String backgroundColor;
    String textColor;
    String fontHeading;
    String fontBody;
    int themeVersion;

    ThemeModel({
        required this.themeId,
        required this.themeName,
        required this.primaryColor,
        required this.secondaryColor,
        required this.backgroundColor,
        required this.textColor,
        required this.fontHeading,
        required this.fontBody,
        required this.themeVersion,
    });

    factory ThemeModel.fromJson(Map<String, dynamic> json) => ThemeModel(
        themeId: json["theme_id"],
        themeName: json["theme_name"],
        primaryColor: json["primary_color"],
        secondaryColor: json["secondary_color"],
        backgroundColor: json["background_color"],
        textColor: json["text_color"],
        fontHeading: json["font_heading"],
        fontBody: json["font_body"],
        themeVersion: json["theme_version"],
    );

    Map<String, dynamic> toJson() => {
        "theme_id": themeId,
        "theme_name": themeName,
        "primary_color": primaryColor,
        "secondary_color": secondaryColor,
        "background_color": backgroundColor,
        "text_color": textColor,
        "font_heading": fontHeading,
        "font_body": fontBody,
        "theme_version": themeVersion,
    };
}
