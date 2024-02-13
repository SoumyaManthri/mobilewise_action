import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import '../../../utils/biometric_auth.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../screens/forms/model/server_form_model.dart';
import '../../../screens/home/model/update_app_version_request_params.dart';
import '../../../services/api_provider.dart';
import '../../../shared/model/common_api_response.dart';
import '../../../shared/model/forms_config.dart';
import '../../../shared/model/forms_config_request_params.dart';
import '../../../shared/model/framework_form.dart';
import '../../../shared/model/theme_model.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/secured_storage_util.dart';
import '../../../utils/shared_preference_util.dart';
import '../../../utils/util.dart';
import '../../login/model/csrf_model.dart';
import '../../login/model/jwt_model.dart';
import '../../login/model/login_response_model.dart';
import '../model/screen_config_model.dart';
import '../model/user_permissions_model.dart';
import '../view_model/home_view_model.dart';

/// Abstract class for the home repository
abstract class HomeRepository {

  Future<UserPermissionsModel?> fetchUserPermissions(BuildContext context);

  Future<ScreensConfigModel?> fetchScreensConfig(
      ScreensConfigModel cachedConfig, BuildContext context);

  getForms(BuildContext context);

  getCachedForms();

  getTheme();

  Future<CommonApiResponse> logout(String token);

  Future<LoginResponseModel> refreshToken(String accessToken,
      String refreshToken, String userName, BuildContext context);

  updateAppVersionOnBackend(String version);
}

/// Concrete class implementation for the home repository
class HomeRepositoryImpl extends HomeRepository {

  @override
  Future<UserPermissionsModel?> fetchUserPermissions(BuildContext context) async{
    try {
      CommonApiResponse response = await ApiProvider().fetchUserPermissions();

      if (response.statusCode != null && response.statusCode == 200 && response.response != null && response.response!.isNotEmpty) {
        UserPermissionsModel userPermissions = UserPermissionsModel.fromJson(response.response!);
        return userPermissions;
      } else if (response.statusCode != null && response.statusCode == 401) {
        await Util.instance.redirectToLoginBecauseOfTokenExpiry(context);
        return null;
      } else {
        return null;
      }
    } on Error catch (e) {
      Util.instance.logMessage('Home Repo', 'Error while fetching user permissions $e');
      return null;
    }
  }

  @override
  Future<ScreensConfigModel?> fetchScreensConfig(
      ScreensConfigModel cachedConfig, BuildContext context) async {
    /// Fetch screens config from server
    ScreensConfigModel? config;
    try {
      // ScreenConfigRequestParams params =
      //     ApiProvider().createScreenConfigParams(cachedConfig.version);

      CommonApiResponse response = await ApiProvider().fetchScreensConfig();

      /// The response could be null in case no new config exists
      /// If so, the older existing config should be loaded from the DB
      /// Returning null if no valid config is returned from the API
      if (response.statusCode != null &&
          response.statusCode == 200 &&
          response.response != null &&
          response.response!.isNotEmpty) {
        config = ScreensConfigModel.fromJson(response.response!);
      } else if (response.statusCode != null && response.statusCode == 401) {
        /// Session expired, redirecting to login screen
        await Util.instance.redirectToLoginBecauseOfTokenExpiry(context);
      }
    } on Error catch (e) {
      Util.instance
          .logMessage('Home Repo', 'Error while fetching screen config $e');
    }

    await getForms(context);
    return config;
  }

  @override
  Future<void> updateAppVersionOnBackend(String version) async {
    /// Update app version on backend
    try {
      UpdateAppVersionRequestParams params =
          ApiProvider().createUpdateAppVersionParams(version);
      await ApiProvider().updateAppVersion(params);
      Util.instance.logMessage(
          'Home Repo', 'Successfully updated app version on backend');
    } on Error catch (e) {
      Util.instance.logMessage(
          'Home Repo', 'Error while updating app version on backend $e');
    }
  }

  @override
  getTheme() async {
    /// Update app version on backend
    try {
      CommonApiResponse response =
          await ApiProvider().fetchTheme(constants.appId);

      if (response.statusCode != null &&
          response.statusCode == 200 &&
          response.response != null &&
          response.response!.isNotEmpty) {
        ThemeModel themeModel = ThemeModel.fromJson(response.response!['theme']);
        AppState.instance.setTheme(themeModel);
      } else if (response.statusCode != null && response.statusCode == 401) {
        Util.instance.logMessage('Home Repo', 'Error while parsing theme');
      }
    } catch (e) {
      Util.instance.logMessage('Home Repo', 'Error while fetching theme -- $e');
    }
  }

  @override
  getForms(BuildContext context) async {
    /// Create params for the forms service -
    /// Fetch the list of forms from the DB, along with their latest versions
    /// Make the API call
    /// If forms are received in the response, save them to the app state and the DB
    /// If not, then handle the case where no forms exist in the DB
    Map<String, int> formsVersionMap = {};

    /// Hive box that stores forms received from server
    var formsConfigBox;
    formsConfigBox = await Hive.openBox(constants.formsBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));
    List<dynamic>? cachedFormsList;
    try {
      cachedFormsList =
          formsConfigBox.get(AppState.instance.userId.toLowerCase());
    } catch (e) {
      Util.instance.logMessage('Home Repo', 'No cached forms exists');
    }

    if (cachedFormsList != null && cachedFormsList.isNotEmpty) {
      /// Cached forms exist
      Util.instance
          .logMessage('Home Repo', 'Cached forms exists -- $cachedFormsList');
      for (ServerFormModel form in cachedFormsList) {
        formsVersionMap[form.formKey] = form.version;
      }
      Util.instance
          .logMessage('Home Repo', 'Cached forms versions -- $formsVersionMap');
    }

    FormsConfigRequestParams params =
        ApiProvider().createFormsConfigParams(formsVersionMap);
    CommonApiResponse response =
        await ApiProvider().fetchFormsConfig(params, true);
    FormsConfig formsConfig = const FormsConfig(formList: []);
    if (response.statusCode != null && response.statusCode == 200) {
      if (response.response != null && response.response!.isNotEmpty) {
        formsConfig = FormsConfig.fromJson(response.response!);
        if (formsConfig.formList.isNotEmpty) {
          Util.instance.logMessage('Home Repo',
              'Server has returned forms ${formsConfig.toString()}');

          /// Only the forms with newer versions will be returned
          /// Make sure the older forms from the cache are also added to AppState
          /// Also, update the local cache list of forms
          List<ServerFormModel> newCachedList = [];

          /// Adding the new received form to the AppState
          AppState.instance.formsList.clear();
          for (ServerFormModel form in formsConfig.formList) {
            try {
              FrameworkForm f = FrameworkForm.fromJson(jsonDecode(form.formJson));
              AppState.instance.formsList.add(f);
              if (form.formType.isNotEmpty) {
                            AppState.instance.formsTypesWithKey[form.formType] = f.formKey;
                          }
              newCachedList.add(form);
              if(form.formType == constants.loginPage){
                await BiometricAuth.instance.updateBiometricIsEnabled(f);
              }
            } catch (e) {
              Util.instance.logMessage("Home Repo", '$e');
            }
          }

          /// Add all the cached forms for which new versions were not received
          /// in the server response
          if (cachedFormsList != null && cachedFormsList.isNotEmpty) {
            for (ServerFormModel form in cachedFormsList) {
              FrameworkForm f =
                  FrameworkForm.fromJson(jsonDecode(form.formJson));
              bool exists = false;
              for (FrameworkForm serverReceivedForm
                  in AppState.instance.formsList) {
                if (f.formKey == serverReceivedForm.formKey) {
                  exists = true;
                }
              }
              if (!exists) {
                /// Cached forms are only added to AppState if we haven't
                /// received a new version for them from the server
                AppState.instance.formsList.add(f);
                if (form.formType != null && form.formType.isNotEmpty) {
                  AppState.instance.formsTypesWithKey[form.formType] =
                      f.formKey;
                }
                newCachedList.add(form);
              }
            }
          }

          /// Refresh the hive DB
          if (cachedFormsList != null && cachedFormsList.isNotEmpty) {
            formsConfigBox.get(AppState.instance.userId.toLowerCase()).clear();
          }
          formsConfigBox.put(
              AppState.instance.userId.toLowerCase(), newCachedList);
        } else {
          /// No new forms exist, all the cached forms should be added to
          /// AppState
          Util.instance
              .logMessage('Home Repo', 'No new forms returned by server');
          AppState.instance.formsList.clear();
          if (cachedFormsList != null && cachedFormsList.isNotEmpty) {
            for (ServerFormModel form in cachedFormsList) {
              FrameworkForm f =
                  FrameworkForm.fromJson(jsonDecode(form.formJson));
              AppState.instance.formsList.add(f);
              if (form.formType != null && form.formType.isNotEmpty) {
                AppState.instance.formsTypesWithKey[form.formType] = f.formKey;
              }
            }
          }
        }
      } else {
        Util.instance.logMessage('Home Repo', 'Invalid response');

        /// No new forms exists
        /// The local DB contains the latest forms
        /// In this case, the existing forms should be loaded from the DB
        AppState.instance.formsList.clear();
        if (cachedFormsList != null && cachedFormsList.isNotEmpty) {
          for (ServerFormModel form in cachedFormsList) {
            FrameworkForm f = FrameworkForm.fromJson(jsonDecode(form.formJson));
            AppState.instance.formsList.add(f);
            if (form.formType != null && form.formType.isNotEmpty) {
              AppState.instance.formsTypesWithKey[form.formType] = f.formKey;
            }
          }
        }
      }
    } else if (response.statusCode != null && response.statusCode == 401) {
      /// Session expired, redirecting to login screen
      await Util.instance.redirectToLoginBecauseOfTokenExpiry(context);
    } else {
      Util.instance.logMessage('Home Repo',
          'Error -- Code:${response.statusCode} -- ${response.message}');

      /// Handle error case
      /// Check if forms exists in the local DB
      AppState.instance.formsList.clear();
      if (cachedFormsList != null && cachedFormsList.isNotEmpty) {
        for (ServerFormModel form in cachedFormsList) {
          FrameworkForm f = FrameworkForm.fromJson(jsonDecode(form.formJson));
          AppState.instance.formsList.add(f);
          if (form.formType != null && form.formType.isNotEmpty) {
            AppState.instance.formsTypesWithKey[form.formType] = f.formKey;
          }
        }
      }
    }
  }

  @override
  getCachedForms() async {
    var formsConfigBox;

    /// Open Hive box for forms
    formsConfigBox = await Hive.openBox(constants.formsBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));
    List<dynamic>? cachedFormsList;
    try {
      /// Fetch cached forms from Hive box
      cachedFormsList =
          formsConfigBox.get(AppState.instance.userId.toLowerCase());
      if (cachedFormsList != null && cachedFormsList.isNotEmpty) {
        AppState.instance.formsList.clear();

        /// Iterate through cached forms and add them to AppState
        for (ServerFormModel form in cachedFormsList) {
          FrameworkForm f = FrameworkForm.fromJson(jsonDecode(form.formJson));
          AppState.instance.formsList.add(f);
          if (form.formType != null && form.formType.isNotEmpty) {
            AppState.instance.formsTypesWithKey[form.formType] = f.formKey;
          }
        }
      }
    } catch (e) {
      Util.instance.logMessage('Home Repo', 'No cached forms exists');
    }
  }

  @override
  Future<CommonApiResponse> logout(String token) async {
    Map<String, String> authHeaders = {
      constants.authorization: token,
      constants.applicationId:constants.appId,
    };
    String authUrl = constants.authBaseUrl + constants.logoutEndpoint;
    http.Response response =
        await http.post(Uri.parse(authUrl), headers: authHeaders);
    CommonApiResponse authResponse =
        CommonApiResponse.fromJson(jsonDecode(response.body));
    return authResponse;
  }

  @override
  Future<LoginResponseModel> refreshToken(
    String accessToken,
    String refreshToken,
    String userName,
    BuildContext context,
    /*String deviceId*/
  ) async {
    String tokenAuth = 'Bearer $accessToken';
    CommonApiResponse authResp = await ApiProvider()
        .refreshTokenRequest(tokenAuth, refreshToken, userName);
    if (authResp.statusCode != null && authResp.statusCode == 200) {
      if (authResp.response != null &&
          authResp.response!.isNotEmpty &&
          authResp.response!.containsKey('token')) {
        /// Converting base64 token to readable string
        String convertedTokenToString = decoded(authResp.response!['token']);
        if (convertedTokenToString.isNotEmpty) {
          /// Converting string and assigning to model class
          JWTModel jwtModel =
              JWTModel.fromJson(json.decode(convertedTokenToString));
          await _setLoginSharedPreferences(
              AppState.instance.userId,
              (jwtModel.preferredUsername == null ||
                      jwtModel.preferredUsername!.isEmpty)
                  ? AppState.instance.userId
                  : jwtModel.preferredUsername!.toString(),
              convertedTokenToString);

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
      } else {
        Provider.of<HomeViewModel>(context, listen: false).logOut(context);
      }
    } else if (authResp.response != null &&
        authResp.response!.isNotEmpty &&
        authResp.response!.containsKey('message')) {
      return LoginResponseModel(false, authResp.response!['message']);
    }
    return LoginResponseModel(false, constants.serverDown);
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
