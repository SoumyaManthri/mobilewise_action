import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:provider/provider.dart';

import '../../../screens/home/view_model/home_view_model.dart';
import '../../../screens/login/model/jwt_model.dart';
import '../../../services/api_provider.dart';
import '../../../shared/model/common_api_response.dart';
import '../../../shared/model/theme_model.dart';
import '../../../shared/view_model/loading_view_model.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/navigation_util.dart';
import '../../../utils/secured_storage_util.dart';
import '../../../utils/shared_preference_util.dart';
import '../../../utils/util.dart';
import '../../forms/view_model/form_view_model.dart';

class SplashViewModel extends LoadingViewModel {
  FormViewModel? formViewModel;

  checkPermissionsAndNavigate(BuildContext context) async {
    /// Checking if the user has enabled the GPS
    await _checkIfGpsEnabled();

    /// Check if all permissions have been given
    var locationStatus = await permission_handler.Permission.location.status;
    var cameraStatus = await permission_handler.Permission.camera.status;

    fetchCachedTheme();

    /// If any permission is denied, navigate to permissions screen
    if (cameraStatus.isDenied ||
        cameraStatus.isPermanentlyDenied ||
        locationStatus.isDenied ||
        locationStatus.isPermanentlyDenied) {
      /// Permissions are needed
      _startSplashTimerAndNavigate(context, constants.permissionsRoute);
    } else {
      /// Permissions have been given, check if user is logged in
      await _checkIfUserIsLoggedIn(context);
    }
  }

  void fetchCachedTheme() async {
    dynamic theme =
        await SecuredStorageUtil.instance.readSecureData(constants.theme);
    //todo remove condition and resolve issue
    if (theme != null) {
      AppState.instance.themeModel = ThemeModel.fromJson(json.decode(theme));
    }
  }

  /// Check if the GPS is enabled and fetching user location
  _checkIfGpsEnabled() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await AppState.instance.location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await AppState.instance.location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    /// Checking if the user has granted the location permission
    permissionGranted = await AppState.instance.location.hasPermission();
    if (permissionGranted == PermissionStatus.granted) {
      /// Fetching the current user location
      AppState.instance.startTrackingUserLocation();
    }
  }

  /// Checking if the user is logged in, from secure storage, and
  /// navigate accordingly
  _checkIfUserIsLoggedIn(BuildContext context) async {
    bool isLoggedIn = await SharedPreferenceUtil.instance
        .getBoolPreference(constants.preferenceIsLoggedIn);
    dynamic userId = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceUserId);
    dynamic username = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceUsername);
    dynamic jwtToken = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceJwtModelString);
    dynamic lastLoginTime = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceLastLogin);
    dynamic jwtTokenString =
        await SecuredStorageUtil.instance.readSecureData(constants.authToken);
    dynamic csrfTokenString =
        await SecuredStorageUtil.instance.readSecureData(constants.csrfToken);

    if (userId != null && username != null && jwtTokenString != null) {
      if (isLoggedIn) {
        /// User is logged in
        try {
          AppState.instance.userId = userId;
          AppState.instance.username = username;
          AppState.instance.jwtTokenString = jwtTokenString;
          AppState.instance.csrfTokenString = csrfTokenString;
          AppState.instance.jwtToken = JWTModel.fromJson(json.decode(jwtToken));
          AppState.instance.lastLogin = lastLoginTime;
        } catch (e) {
          Util.instance.logMessage(
              'Splash View Model', 'Error while parsing JWT token -- $e');
        } finally {
          _startSplashTimerAndNavigate(context, constants.homeRoute);
        }
      } else {
        navigateToLogin(context);
      }
    } else {
      /// User has never logged in
      navigateToLogin(context);
    }
  }

  /// 1. This method is called for navigation to login screen if the user
  /// is not trying to to open the app from iQ Toolbox application
  /// 2. And also if the user is trying to open the app from the
  /// iQ Toolbox application (In this case the 'usernameFromToolbox'
  /// parameter is not null)
  void navigateToLogin(BuildContext context) {
    /// User is logged out
    _startSplashTimerAndNavigate(context, constants.loginRoute);
  }

  /// Navigator function based on route argument
  _startSplashTimerAndNavigate(BuildContext context, String routeName) {
    formViewModel?.currentForm = FormViewModel.emptyFormData();
    Timer(const Duration(seconds: constants.splashDuration), () async {
      if (routeName == constants.loginRoute) {
        NavigationUtil.instance.navigateToLoginScreen(context);
      } else if (routeName == constants.homeRoute) {
        if (checkTimeIsValid()) {
          await SecuredStorageUtil.instance.writeSecureData(
              constants.preferenceLastLogin,
              DateTime.now().millisecondsSinceEpoch.toString());
          NavigationUtil.instance.navigateToHomeScreen(context, false);
        } else {
          Provider.of<HomeViewModel>(context, listen: false).logOut(context);
        }
      } else {
        NavigationUtil.instance.navigateToPermissionsScreenAndPop(context);
      }
    });
  }

  /// Checks the nbf and exp is between the current time
  ///
  /// @return true or false
  bool checkTimeIsValid() {
    int? notBefore = AppState.instance.jwtToken.iat;
    int? expirationTime = AppState.instance.jwtToken.exp;
    String? lastLogin = AppState.instance.lastLogin;
    int currentTime = DateTime.now().millisecondsSinceEpoch + 6000;
    if (lastLogin != null && lastLogin.isNotEmpty) {
      return isBefore(int.parse(lastLogin), currentTime);
    } else if ((notBefore != null) && (expirationTime != null)) {
      DateTime fromStr = DateTime.fromMillisecondsSinceEpoch(notBefore * 1000);
      DateTime afterStr =
          DateTime.fromMillisecondsSinceEpoch(expirationTime * 1000);
      return !isBefore(currentTime, fromStr.millisecondsSinceEpoch) &&
          !isAfter(currentTime, afterStr.millisecondsSinceEpoch);
    } else {
      return false;
    }
  }

  /// Check if date is before the date
  ///
  /// @param fromDate     from the date
  /// @param dateIsBefore the to be compared
  /// @return true or false
  static bool isBefore(int fromDate, int dateIsBefore) {
    var fromStr = DateTime.fromMillisecondsSinceEpoch(fromDate);
    var beforeStr = DateTime.fromMillisecondsSinceEpoch(dateIsBefore);
    return fromStr.isBefore(beforeStr);
  }

  /// Check if date is After the date
  ///
  /// @param fromDate     from the date
  /// @param dateIsAfter the to be compared
  /// @return true or false
  static bool isAfter(int fromDate, int dateIsAfter) {
    var fromStr = DateTime.fromMillisecondsSinceEpoch(fromDate);
    var afterStr = DateTime.fromMillisecondsSinceEpoch(dateIsAfter);
    return fromStr.isAfter(afterStr);
  }

  void updateDownloadCount(BuildContext context) async {
    var isFirstAppRun = await SecuredStorageUtil.instance
        .readSecureData(constants.firstAppLaunch);
    if (isFirstAppRun == null) {
      CommonApiResponse response =
          await ApiProvider().updateInstallationCount(constants.appId);
      if (response.statusCode == 200) {
        await SecuredStorageUtil.instance
            .writeSecureData(constants.firstAppLaunch, true);
      }
    }
  }
}
