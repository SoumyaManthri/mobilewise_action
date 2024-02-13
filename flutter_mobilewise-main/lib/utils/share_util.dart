import 'package:url_launcher/url_launcher.dart';

class ShareUtil {
  static ShareUtil? _instance;

  ShareUtil._();

  static ShareUtil get instance => _instance ??= ShareUtil._();

  Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  Future<void> launchEmail(String email, String subject, String body) async {
    String emailUrl = "mailto:$email?subject=$subject&body=$body";
    var uri = Uri.parse(emailUrl);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $uri';
    }
  }
}
