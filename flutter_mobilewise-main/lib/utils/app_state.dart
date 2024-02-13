import 'dart:convert';

import 'package:event_bus/event_bus.dart';
import 'package:flutter_mobilewise/shared/model/form_widget_data.dart';
import 'package:flutter_mobilewise/utils/secured_storage_util.dart';
import 'package:location/location.dart';

import '../screens/home/model/user_permissions_model.dart';
import '../screens/login/model/jwt_model.dart';
import '../shared/event/app_events.dart';
import '../shared/model/framework_form.dart';
import '../../../utils/common_constants.dart' as constants;
import '../shared/model/theme_model.dart';

class AppState {
  static AppState? _instance;

  AppState._();

  static AppState get instance => _instance ??= AppState._();

  EventBus eventBus = EventBus();

  late String userId;
  late String username;
  late String? jwtTokenString;
  late String? csrfTokenString;
  late JWTModel jwtToken;
  late String? hiveEncryptionKey;
  late String? lastLogin;
  UserPermissionsModel? userPermissions;
  late ThemeModel themeModel = ThemeModel(
      themeId: "themeId",
      themeName: "themeName",
      primaryColor: "FFFBD002",
      secondaryColor: "FFFBD002",
      backgroundColor: "FFFBD002",
      textColor: "FFFBD002",
      fontHeading: "FFFBD002",
      fontBody: "fontBody",
      themeVersion: 1);

  /// This variable is initialized based on the flavor of the app that is running
  /// Possible values -
  /// 1. DEV
  /// 2. QA
  /// 3. PROD
  late String? environment;

  /// The forms list received from the server, used to create the form screens
  List<FrameworkForm> formsList = [];
  Map<String, String> formsTypesWithKey = Map();

  /// The current user location
  Location location = Location();
  LocationData? currentUserLocation;

  /// Flag for app background sync
  bool isSyncInProgress = false;

  /// Tracking user location
  startTrackingUserLocation() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      /// User current location
      currentUserLocation = currentLocation;
    });
  }

  /// 1. This map stores all the key value pairs of the data entered by a user
  /// while they fill the form.
  /// 2. This is not the map that is submitted to the backend when the user tries
  /// to submit the form.
  /// 3. When the user reaches a preview form, we create a new map, that contains
  /// all the user entered data based on the choices they make to traverse the
  /// form based on the decision nodes.
  /// Example - For the 'Report Failure' form, the user can select a 'Thermal
  /// Event' as the discrepancy, and fill the data for it. But at some point,
  /// if the user goes back and changes the discrepancy to 'Freight Damage', then
  /// we will have to clear some of the fields for 'Thermal Event'.
  Map<String, dynamic> _formTempMap = {};
  Map<String, FormWidgetData> _formTempWidgetMap = {};

  /// Getter for formTempMap
  Map<String, dynamic> get formTempMap => _formTempMap;

  Map<String, FormWidgetData> get formTempWidgetMap => _formTempWidgetMap;

  /// Adding a key and value pair to formTempMap
  addToFormTempMap(String key, dynamic value) {
    _formTempMap[key] = value;
    eventBus.fire(FormTempMapChangeEvent());
  }

  /// Clearing formTempMap
  clearFormTempMap() {
    _formTempMap.clear();
  }

  /// Remove key value pair from tempMap
  removeFromFormTempMap(String key) {
    _formTempMap.remove(key);
    eventBus.fire(FormTempMapChangeEvent());
  }

  /// Adding a key and value pair to formTempMap
  addToFormTempWidgetMap(String key,  FrameworkFormField field, String entity) {
    _formTempWidgetMap[key] = FormWidgetData(field, entity);
    // eventBus.fire(FormTempMapChangeEvent());
  }

  /// Clearing formTempMap
  clearFormTempWidgetMap() {
    _formTempWidgetMap.clear();
  }

  /// Remove key value pair from tempMap
  removeFromTempWidgetMap(String key) {
    _formTempWidgetMap.remove(key);
    // eventBus.fire(FormTempMapChangeEvent());
  }

  setTheme(ThemeModel themeModel) async {
    this.themeModel = themeModel;
    await SecuredStorageUtil.instance
        .writeSecureData(constants.theme, jsonEncode(themeModel.toJson()));
  }
}
