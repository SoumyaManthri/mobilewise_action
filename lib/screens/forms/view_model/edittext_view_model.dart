import 'package:flutter/foundation.dart' show ChangeNotifier;

class EditTextViewModel with ChangeNotifier {
  Map<String, int> keyToLengthMap = {};

  setLength(String key, int value) {
    keyToLengthMap[key] = value;
    notifyListeners();
  }
}