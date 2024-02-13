import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../screens/login/model/jwt_model.dart';
import '../../../shared/view_model/loading_view_model.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/navigation_util.dart';
import '../../../utils/secured_storage_util.dart';
import '../../../utils/shared_preference_util.dart';
import '../../../utils/util.dart';

class PermissionsViewModel extends LoadingViewModel {
  requestPermissionsAndNavigate(BuildContext context) async {
    /// Checking if the user has given runtime permissions
    bool arePermissionsGiven = await _checkPermissions();
    if (arePermissionsGiven) {
      /// Check if user is logged in, and navigate
      _checkIfUserIsLoggedIn(context);
    } else {
      /// Permissions not granted, show permissions dialog
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.location,
      ].request();
      if (statuses != null && statuses.isNotEmpty) {
        PermissionStatus? locationPermission = statuses[Permission.location];
        PermissionStatus? cameraPermission = statuses[Permission.camera];
        if (locationPermission == PermissionStatus.granted &&
            cameraPermission == PermissionStatus.granted) {
          /// All permissions are granted
          _checkIfUserIsLoggedIn(context);
        } else if (locationPermission == PermissionStatus.denied ||
            cameraPermission == PermissionStatus.denied) {
          /// One or all permissions are denied
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(constants.permissionsErrorMsg),
          ));
        } else if (locationPermission == PermissionStatus.permanentlyDenied ||
            cameraPermission == PermissionStatus.permanentlyDenied) {
          /// One or all permissions are permanently denied, opening settings
          openAppSettings();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(constants.permissionsErrorMsg),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.permissionsErrorMsg),
        ));
      }
    }
  }

  _checkPermissions() async {
    /// Check if all permissions have been given
    var cameraStatus = await Permission.camera.status;
    var locationStatus = await Permission.location.status;
    if (locationStatus.isDenied ||
        cameraStatus.isDenied ||
        locationStatus.isPermanentlyDenied ||
        cameraStatus.isPermanentlyDenied) {
      /// Permissions are needed
      return false;
    } else {
      /// Permissions have been given
      return true;
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
          AppState.instance.csrfTokenString = csrfTokenString;
          AppState.instance.jwtTokenString = jwtTokenString;
          AppState.instance.jwtToken = JWTModel.fromJson(json.decode(jwtToken));
        } catch (e) {
          Util.instance.logMessage(
              'Permissions View Model', 'Error while parsing JWT token -- $e');
        } finally {
          NavigationUtil.instance.navigateToHomeScreen(context,false);
        }
      } else {
        navigateToLogin(context);
      }
    } else {
      /// User has never logged in
      navigateToLogin(context);
    }
  }

  void navigateToLogin(BuildContext context) {
    /// User is logged out
    NavigationUtil.instance.navigateToLoginScreen(context);
  }
}
