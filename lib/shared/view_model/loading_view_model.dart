import 'package:flutter/foundation.dart' show ChangeNotifier;

class LoadingViewModel with ChangeNotifier {
  bool _isLoading = false;
  bool _isButtonLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  bool get isButtonLoading => _isButtonLoading;

  set isButtonLoading(bool value) {
    _isButtonLoading = value;
  }
}