import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../screens/forms/model/notification_count_request_params.dart';
import '../../../screens/home/model/screen_config_model.dart';
import '../../../services/api_provider.dart';
import '../../../services/app_sync_service.dart';
import '../../../shared/model/common_api_response.dart';
import '../../../shared/model/framework_form.dart';
import '../../../shared/view_model/loading_view_model.dart';
import '../../../utils/network_util.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/navigation_util.dart';
import '../../../utils/secured_storage_util.dart';
import '../../../utils/shared_preference_util.dart';
import '../../../utils/util.dart';
import '../model/landing_page_model.dart';
import '../model/user_permissions_model.dart';
import '../repository/home_repo.dart';

class HomeViewModel extends LoadingViewModel {
  HomeViewModel({
    required this.repo,
  });

  final HomeRepository repo;
  var encryptedHomeScreenConfigBox;

  LandingPageModel get homeModel => _homeModel;

  set homeModel(LandingPageModel homeModel) {
    _homeModel = homeModel;
    notifyListeners();
  }

  Future<void> updateAppVersionOnBackend() async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      String version = await Util.instance.getAppVersion();
      try {
        await repo.updateAppVersionOnBackend(version);
      } catch (e) {
        Util.instance.logMessage(
            'Home View Model', 'Error while updating app version on server $e');
      }
    }
  }

  Future<void> fetchUserPermissions(BuildContext context) async{
    if (await networkUtils.hasActiveInternet()) {
      try {
        isLoading = true;
        UserPermissionsModel? userPermissions = await repo.fetchUserPermissions(context);
        if (userPermissions != null && userPermissions.permissions.isNotEmpty) {
          AppState.instance.userPermissions = userPermissions;
        }
      } catch (e) {
        Util.instance.logMessage('Home View Model', 'Error while fetching user permissions $e');
      }
    }
  }

  Future<void> fetchScreenConfig(BuildContext context) async {
    /// Fetching the cached config from the hive DB
    /// Opening encrypted hive box
    encryptedHomeScreenConfigBox = await Hive.openBox(
        constants.homeScreenConfigBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));
    ScreensConfigModel cachedConfig = const ScreensConfigModel();
    try {
      cachedConfig = encryptedHomeScreenConfigBox
          .get(AppState.instance.userId.toLowerCase());
    } catch (e) {
      Util.instance.logMessage('Home View Model', 'No cached config exists');
    }

    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      try {
        isLoading = true;
        ScreensConfigModel? config =
            await repo.fetchScreensConfig(cachedConfig, context);
        if (config != null && config.screensJsonString.isNotEmpty) {
          /// Screen config string is returned from the API, parsing it
          _homeModel =
              LandingPageModel.fromJson(jsonDecode(config.screensJsonString));

          /// Adding this parsed config to the encrypted hive box
          encryptedHomeScreenConfigBox.put(
              AppState.instance.userId.toLowerCase(), config);
        } else {
          /// No new config exists, OR
          /// Network error occurred while fetching config
          /// The existing config should be loaded from the DB if available
          try {
            _homeModel = LandingPageModel.fromJson(
                jsonDecode(cachedConfig.screensJsonString));
          } catch (e) {
            Util.instance.logMessage('Home View Model',
                'Error while parsing cached screen config $e');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(constants.noNetworkAvailability),
            ));
          }
        }
      } catch (e) {
        Util.instance.logMessage(
            'Home View Model', 'Error while fetching screen config $e');
      }
      isLoading = false;
      notifyListeners();
    } else if (cachedConfig.screensJsonString.isNotEmpty) {
      /// Cached config available
      try {
        _homeModel = LandingPageModel.fromJson(
            jsonDecode(cachedConfig.screensJsonString));
      } catch (e) {
        Util.instance.logMessage(
            'Home View Model', 'Error while parsing cached screen config $e');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.noNetworkAvailability),
        ));
      }

      /// Fetching forms(From cache - Hive DB)
      await repo.getCachedForms();

      isLoading = false;
      notifyListeners();
    } else {
      Util.instance.logMessage('Home View Model',
          'Error while fetching screen config - No internet connection');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
  }

  /**
   * Fetch form API
   */
  Future<void> fetchForms(BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      try {
        isLoading = true;
        await repo.getForms(context);
      } catch (e) {
        Util.instance.logMessage(
            'Home View Model', 'Error while fetching screen config $e');
        isLoading = false;
      }
      notifyListeners();
    }
    else {
      Util.instance.logMessage('Home View Model',
          'Error while fetching screen config - No internet connection');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
  }



  /// 1. Clear shared preference
  /// 2. Clear app state
  /// 3. Redirect to login screen
  Future<bool> logOut(BuildContext context) async {
    /// Call the logout API
    if (AppState.instance.jwtTokenString != null &&
        AppState.instance.jwtTokenString!.isNotEmpty) {
      CommonApiResponse response =
          await repo.logout('Bearer ${AppState.instance.jwtTokenString}');

      if (response != null && response.statusCode == 200) {
        await _setLogoutSharedPreferences();
        AppState.instance.userId = '';
        AppState.instance.username = '';
        AppState.instance.jwtTokenString = '';
        AppState.instance.csrfTokenString = '';
        AppState.instance.userPermissions = null;

        AppState.instance.formsTypesWithKey.clear();
        AppState.instance.formTempMap.clear();
        /// Navigate to login screen
        NavigationUtil.instance.navigateToLoginScreen(context);
      } else if (response != null &&
          response.statusCode != null &&
          response.statusCode == 401) {
        /// Session expired, redirecting to login screen
        await Util.instance.redirectToLoginBecauseOfTokenExpiry(context);
      } else if (response != null &&
          response.response != null &&
          response.response!.containsKey('message')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.response!['message']),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.logoutErrorMsg),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.logoutErrorMsg),
      ));
    }

    return true;
  }

  /// Setting the shared preferences when the user clicks on 'Logout'
  _setLogoutSharedPreferences() async {
    await SharedPreferenceUtil.instance.setPreferenceValue(
        constants.preferenceIsLoggedIn, false, constants.preferenceTypeBool);
    await SharedPreferenceUtil.instance.setPreferenceValue(
        constants.fingerPrint, false, constants.preferenceTypeBool);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserId, '');
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUsername, '');
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceJwtModelString, '');
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceLastLogin, '');
    await SecuredStorageUtil.instance
        .writeSecureData(constants.refreshToken, '');
  }

  navigateToAboutScreen(BuildContext context) {
    Navigator.pop(context);
    NavigationUtil.instance.navigateToAboutScreen(context);
  }

  navigateToChangePasswordScreen(BuildContext context) {
    Navigator.pop(context);
    NavigationUtil.instance.navigateToChangePasswordScreen(context);
  }

  navigateToFormScreen(BuildContext context, LandingPageButton button) {
    Navigator.pop(context);
    NavigationUtil.instance.navigateToFormScreen(context, button.child);
  }

  navigateToFormScreenWithoutPop(
      BuildContext context, LandingPageButton button) {
    NavigationUtil.instance.navigateToFormScreen(context, button.child);
  }

  /// This function is called to perform the force sync of the application
  /// 1. All the cached data is first deleted from the application.
  /// 2. Then, the App Sync is called to fetch data.
  forceSync(BuildContext context) async {
    Navigator.pop(context);
    try {
      if (AppState.instance.isSyncInProgress) {
        Util.instance.logMessage('Home View Model',
            'Error starting force sync -- app background sync in progress');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.noForceSyncErrorMsg),
        ));
        return;
      }

      bool isOnline = await networkUtils.hasActiveInternet();
      if (isOnline) {
        Util.instance.logMessage('Home View Model',
            'Start of forced sync -- started clearing cached data');

        await _clearCachedFormsData();
        await _clearCachedSubmissionListsData();
        await _clearCachedOfflineSubmissionsData();
        await _clearCachedMediaEntriesData();
        await _clearCachedRejectedSubmissionsFormsData();
        await _clearCachedSettingsData();
        await _clearCachedDropdownsData();

        Util.instance.logMessage('Home View Model',
            'Force sync -- cleared cached data  -- syncing fresh data now');

        AppBackGroundSyncService appBackGroundSyncService =
            AppBackGroundSyncService();
        await appBackGroundSyncService.execute(context);

        Util.instance.logMessage('Home View Model', 'End of forced sync');
      } else {
        Util.instance.logMessage(
            'Home View Model', 'Forced sync failed -- no active internet');
      }
    } catch (e) {
      Util.instance.logMessage(
          'Home View Model', 'Error while force sync execution -- $e');
    }
  }

  /// This method clears the cached forms in the Hive box
  _clearCachedFormsData() async {
    var box = await Hive.openBox(constants.formsBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));
    await box.clear();
    await box.close();
  }

  /// This method clears the cached submissions list in the Hive box
  _clearCachedSubmissionListsData() async {
    var box = await Hive.openBox(constants.fetchedSubmissionsBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));
    await box.clear();
    await box.close();
  }

  /// This method clears the cached offline submissions in the Hive box
  _clearCachedOfflineSubmissionsData() async {
    var box = await Hive.openBox(constants.submissionsBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));
    await box.clear();
    await box.close();
  }

  /// This method clears the cached media entries in the Hive box
  _clearCachedMediaEntriesData() async {
    var box = await Hive.openBox(constants.formMediaBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));
    await box.clear();
    await box.close();
  }

  /// This method clears the cached rejected offline submissions in the Hive box
  _clearCachedRejectedSubmissionsFormsData() async {
    var box = await Hive.openBox(constants.rejectedSubmissionsBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));
    await box.clear();
    await box.close();
  }

  /// This method clears the cached settings in the Hive box
  _clearCachedSettingsData() async {
    var box = await Hive.openBox(constants.submissionsBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));
    await box.clear();
    await box.close();
  }

  /// This method clears the cached dropdown values in the Hive box
  _clearCachedDropdownsData() async {
    var box = await Hive.openBox(constants.dropdownValuesBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));
    await box.clear();
    await box.close();
  }

  Future<void>? checkTokenValidation(BuildContext context) async {
    int? notBefore = AppState.instance.jwtToken.iat;
    int? expirationTime = AppState.instance.jwtToken.exp;
    String? lastLogin = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceLastLogin);
    if (expirationTime != null && lastLogin != null && lastLogin.isNotEmpty) {
      DateTime expirationDateTime =
          DateTime.fromMillisecondsSinceEpoch(expirationTime * 1000);
      DateTime notBeforeDateTime =
          DateTime.fromMillisecondsSinceEpoch(notBefore! * 1000);
      DateTime lastLoginDateTime =
          DateTime.fromMillisecondsSinceEpoch(int.parse(lastLogin));
      int time = expirationDateTime.millisecondsSinceEpoch -
          notBeforeDateTime.millisecondsSinceEpoch;
      int halfTime =
          notBeforeDateTime.millisecondsSinceEpoch + ((time) / 2).toInt();
      DateTime halfTimeDate =
          DateTime.fromMillisecondsSinceEpoch((halfTime).toInt());
      if (lastLoginDateTime.millisecondsSinceEpoch >
          halfTimeDate.millisecondsSinceEpoch) {
        validateUserSession(context);
      }
    }
  }

  /// Validating the data by calling the refresh token
  /// if internet is on else reset the userdata
  Future<void> validateUserSession(BuildContext context) async {
    dynamic refreshToken = await SecuredStorageUtil.instance
        .readSecureData(constants.refreshToken);
    dynamic username = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceUsername);
    dynamic accessToken = AppState.instance.jwtTokenString;
    if (await networkUtils.hasActiveInternet() && refreshToken != null) {
      await repo.refreshToken(accessToken, refreshToken, username, context);
    }
  }

  LandingPageModel _homeModel = const LandingPageModel();

  getTheme() async {
    await repo.getTheme();
  }

  Future<bool> getIsBioMetricEnabled() async{
    bool isLoggedIn = await SharedPreferenceUtil.instance
        .getBoolPreference(constants.fingerPrint);

    return isLoggedIn;
  }

}
