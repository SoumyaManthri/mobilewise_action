import 'package:flutter/material.dart';

import '../../../screens/login/model/login_response_model.dart';
import '../../../screens/login/repository/login_repo.dart';
import '../../../shared/view_model/loading_view_model.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/navigation_util.dart';
import '../../../utils/network_util.dart';
import '../../../utils/shared_preference_util.dart';
import '../../../utils/util.dart';

class LoginViewModel extends LoadingViewModel {
  LoginViewModel({
    required this.repo,
  });

  final LoginRepository repo;

  Future<String> encryptPassword(String userId, String password, BuildContext context) async {
    /// Converting username and password to base64 by combining
    String userNamePasswordBase64 = await Util.instance.getConvertedBase64String('$userId:$password');
    String auth64 = 'Basic $userNamePasswordBase64';
    return auth64;
  }

  Future<void> authenticate(
      String userId, String passwordBase64, BuildContext context, bool isFromToolbox) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      if (!await restrictLoginAttempts()) {
        late LoginResponseModel loginResponse;
        isLoading = true;
        try {
          loginResponse = await repo.authenticate(userId, passwordBase64, context);
        } catch (e) {
          loginResponse = LoginResponseModel(false, constants.genericErrorMsg);
          Util.instance
              .logMessage('Login Model', 'Error while authenticating $e');
        }
        if (loginResponse.isSuccessful) {
          /// Login is successful
          /// Check if the user branch is available in the JWT token
          /// If the branch is available, redirect to home screen
          /// If the branch is not available, redirect to post login form
          isLoading = false;
          notifyListeners();

          NavigationUtil.instance.navigateToHomeScreen(context,true);
        } else {
          /// Login is unsuccessful
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(loginResponse.message),
          ));
          if (isFromToolbox) {
            NavigationUtil.instance.navigateToLoginScreen(context);
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.toManyLoginAttempts),
        ));
        if (isFromToolbox) {
          NavigationUtil.instance.navigateToLoginScreen(context);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
      if (isFromToolbox) {
        NavigationUtil.instance.navigateToLoginScreen(context);
      }
    }
  }

  /// Restricting user more then 10 attempts
  /// If user reaches 10 attempts then he has to wait for 15 minutes
  Future<bool> restrictLoginAttempts() async {
    int? attempts = await SharedPreferenceUtil.instance
        .getIntPreference(constants.preferenceLoginAttempts);
    double? lastAttemptTime = await SharedPreferenceUtil.instance
        .getDoublePreference(constants.preferenceLastLoginTime);
    double timeDiff =
        (DateTime.now().millisecondsSinceEpoch - lastAttemptTime) / 1000;
    if (timeDiff > constants.lockOutTime) {
      attempts = 0;
      await SharedPreferenceUtil.instance.setPreferenceValue(
          constants.preferenceLoginAttempts, attempts,
          constants.preferenceTypeInt);
    }
    attempts = attempts + 1;
    if (attempts >= constants.lockOutAttempts &&
        timeDiff <= constants.lockOutTime) {
      return true;
    }
    await SharedPreferenceUtil.instance.setPreferenceValue(
        constants.preferenceLoginAttempts, attempts, constants.preferenceTypeInt);
    await SharedPreferenceUtil.instance.setPreferenceValue(
        constants.preferenceLastLoginTime,
        double.parse(DateTime.now().millisecondsSinceEpoch.toString()),
        constants.preferenceTypeDouble);
    return false;
  }

  navigateToForgotPasswordScreen(BuildContext context) {
    /// Navigating user to forgot password screen
    NavigationUtil.instance.navigateToForgotPasswordScreen(context);
  }
}
