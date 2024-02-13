import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../screens/login/model/jwt_model.dart';
import '../../../screens/login/model/login_response_model.dart';
import '../../../services/api_provider.dart';
import '../../../shared/model/common_api_response.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/secured_storage_util.dart';
import '../../../utils/shared_preference_util.dart';
import '../../../utils/util.dart';
import '../model/csrf_model.dart';

/// Abstract class for the home repository
abstract class LoginRepository {
  Future<LoginResponseModel> authenticate(
      String userId, String passwordBase64, BuildContext context);
}

/// Concrete class implementation for the home repository
class LoginRepositoryImpl extends LoginRepository {
  @override
  Future<LoginResponseModel> authenticate(
      String userId, String passwordBase64, BuildContext context) async {
    if (userId.isNotEmpty && passwordBase64.isNotEmpty) {
      /// Calling login API
      LoginResponseModel loginResponseModel = await logIn(
          context: context, credentials: passwordBase64, userId: userId);

      return loginResponseModel;
    } else {
      return LoginResponseModel(false, constants.invalidCredentialsErrorMsg);
    }
  }

  /// Calling Login API and handing the response..
  /// If it is success we are updating to controller to
  Future<LoginResponseModel> logIn({
    required BuildContext context,
    required String credentials,
    required String userId,
  }) async {
    CommonApiResponse authResp = await authRequest(credentials);
    if (authResp.statusCode != null && authResp.statusCode == 200) {
      if (authResp.response != null &&
          authResp.response!.containsKey('token')) {
        /// Converting base64 token to readable string
        String convertedTokenToString = decoded(authResp.response!['token']);
        if (convertedTokenToString.isNotEmpty) {
          /// Converting string and assigning to model class
          JWTModel jwtModel =
              JWTModel.fromJson(json.decode(convertedTokenToString));
          await _setLoginSharedPreferences(
              userId,
              (jwtModel.preferredUsername == null ||
                      jwtModel.preferredUsername!.isEmpty)
                  ? userId
                  : jwtModel.preferredUsername!.toString(),
              convertedTokenToString);

          /// Set token string to app state
          AppState.instance.jwtTokenString = authResp.response!['token'];
          if (AppState.instance.jwtTokenString != null &&
              AppState.instance.jwtTokenString!.isNotEmpty) {
            getCSRFToken(AppState.instance.jwtTokenString!);
          }
          await SecuredStorageUtil.instance.writeSecureData(
              constants.authToken, authResp.response!['token']);
          await SecuredStorageUtil.instance.writeSecureData(
              constants.refreshToken, authResp.response!['refresh_token']);
          return LoginResponseModel(true, constants.loggedInSucc);
        }
      }
    } else if (authResp.response != null &&
        authResp.response!.containsKey('message')) {
      return LoginResponseModel(false, authResp.response!['message']);
    } else if (authResp.message != null && authResp.message!.isNotEmpty) {
      return LoginResponseModel(false, authResp!.message!);
    }

    return LoginResponseModel(false, constants.serverDown);
  }

  /// Calling login API
  static Future<CommonApiResponse> authRequest(String credentials) async {
    Map<String, String> authHeaders = {
      constants.authorization: credentials,
      constants.accept: constants.headerJson,
      constants.applicationId:constants.appId,
    };
    String authUrl = constants.authBaseUrl + constants.loginEndpoint;
    http.Response response =
        await http.post(Uri.parse(authUrl), headers: authHeaders);
    CommonApiResponse authResponse =
        CommonApiResponse.fromJson(jsonDecode(response.body));
    return authResponse;
  }

  /// Splitting the token to list and checking size.
  /// If equals 3 then decoding token and  returning the string
  String decoded(String jwtEncoded) {
    List split = jwtEncoded.split(".");
    if (split.length == 3) {
      return decodeBase64(split[1]);
    } else {
      return '';
    }
  }

  /// Decoding the string
  String decodeBase64(String strDecode) {
    if (strDecode.isNotEmpty) {
      const Base64Codec base64Url = Base64Codec.urlSafe();
      String s = base64.normalize(strDecode);
      Uint8List decodedInt = base64Url.decode(s);
      String decodedString = utf8.decode(decodedInt);
      return decodedString;
    } else {
      return '';
    }
  }

  /// Saving user logged in status, userId, username and jwt token
  /// Initialize userId and username to app state
  _setLoginSharedPreferences(
      String userId, String username, String jwtModelString) async {
    await SharedPreferenceUtil.instance.setPreferenceValue(
        constants.preferenceIsLoggedIn, true, constants.preferenceTypeBool);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserId, userId);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUsername, username);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceJwtModelString, jwtModelString);

    try {
      AppState.instance.userId = userId;
      AppState.instance.username = username;
      AppState.instance.jwtToken =
          JWTModel.fromJson(json.decode(jwtModelString));
    } catch (e) {
      Util.instance
          .logMessage('Login Repo', 'Error while parsing JWT token -- $e');
    }
  }

  getCSRFToken(String jwtTokenString) async {
    CommonApiResponse response =
        await ApiProvider().csrfTokenRequest(jwtTokenString);

    try {
      if (response.statusCode != null &&
          response.statusCode == 200 &&
          response.response != null &&
          response.response!.isNotEmpty) {
        CSRFModel.fromJson(response.response!);
        AppState.instance.csrfTokenString =
            CSRFModel.fromJson(response.response!).tokens?.csrf;
        await SecuredStorageUtil.instance.writeSecureData(
            constants.csrfToken, AppState.instance.csrfTokenString);
      } else if (response.statusCode != null && response.statusCode == 401) {
        Util.instance
            .logMessage('Login Repo', 'Error while parsing CSRF token');
      }
    } catch (e) {
      Util.instance
          .logMessage('Login Repo', 'Error while parsing CSRF token -- $e');
    }
  }
}
