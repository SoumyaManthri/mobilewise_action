import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../screens/forms/model/entity_instance_model.dart';
import '../screens/forms/model/fetch_submissions_request_params.dart';
import '../screens/forms/model/form_submission_request_params.dart';
import '../screens/forms/model/sending_fcm_token_model.dart';
import '../screens/forms/model/submitted_data_model.dart';
import '../screens/home/model/update_app_version_request_params.dart';
import '../shared/model/common_api_response.dart';
import '../shared/model/forms_config_request_params.dart';
import '../shared/model/screen_config_request_params.dart';
import '../utils/app_state.dart';
import '../utils/common_constants.dart' as constants;
import '../utils/util.dart';

/// This class contains all the API calls used by the application
class ApiProvider {
  /// API call to fetch the latest screens config to populate the landing page
  Future<CommonApiResponse> fetchScreensConfig() async {
    try {
      Map<String, String> tokenHeaders = {
        constants.authorization: 'Bearer ${AppState.instance.jwtTokenString!}',
        constants.accept: constants.headerJson,
        constants.headerContentType: constants.headerJson,
      };
      String url =
          '${constants.baseUrl}${constants.screensConfigEndpoint}/${AppState.instance.jwtToken.sub!}';

      debugPrint("HEADER===>$tokenHeaders");
      debugPrint("URL===>$url");
      Response response = await get(Uri.parse(url), headers: tokenHeaders);
      debugPrint("RESPONSE===>${response.body}");

      return CommonApiResponse.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      Util.instance.logMessage('Exception: $error', 'StackTrace: $stacktrace');
      return CommonApiResponse.withError('Error fetching screens config!');
    }
  }

  /// Method to create the params for the screens config API
  createScreenConfigParams(int version) {
    return ScreenConfigRequestParams(version, constants.appId);
  }

  /// API call to fetch user permissions
  Future<CommonApiResponse> fetchUserPermissions() async {
    try {
      Map<String, String> tokenHeaders = {
        constants.authorization: 'Bearer ${AppState.instance.jwtTokenString}',
        constants.csrf: '${AppState.instance.csrfTokenString}',
      };
      String url =
          '${constants.baseUrl}${constants.userPermissionsEndPoint}/${AppState.instance.jwtToken.sub}/${constants.appId}';

      debugPrint("HEADER===>$tokenHeaders");
      debugPrint("URL===>$url");

      Response response = await get(Uri.parse(url), headers: tokenHeaders);
      debugPrint("RESPONSE===>${response.body}");

      return CommonApiResponse.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      Util.instance.logMessage('Exception: $error', 'StackTrace: $stacktrace');
      return CommonApiResponse.withError('Error fetching user permissions');
    }
  }

  /// API call to fetch the latest forms config to populate the forms
  Future<CommonApiResponse> fetchFormsConfig(
      FormsConfigRequestParams params, bool isAuthenticate) async {
    try {
      Response response;
      String url = constants.baseUrl + constants.formsConfigEndpoint;

      Map<String, dynamic> params = {
        'application_id': constants.appId,
        'is_authenticated': isAuthenticate
      };
      if (isAuthenticate) {
        Map<String, String> tokenHeaders = {
          constants.authorization:
              'Bearer ${AppState.instance.jwtTokenString!}',
          constants.accept: constants.headerJson,
          constants.headerContentType: constants.headerJson,
        };
        response = await post(Uri.parse(url),
            headers: tokenHeaders, body: json.encode(params));
      } else {
        Map<String, String> tokenHeaders = {
          constants.accept: constants.headerJson,
          constants.headerContentType: constants.headerJson,
        };
        response = await post(Uri.parse(url),
            headers: tokenHeaders, body: json.encode(params));
      }

      // String jsonString = await rootBundle.loadString(constants.formsJson);
      String jsonString = response.body;
      debugPrint("RESPONSE===>${jsonDecode(jsonString)}");
      return CommonApiResponse.fromJson(jsonDecode(jsonString));
    } catch (error, stacktrace) {
      Util.instance.logMessage('Exception: $error', 'StackTrace: $stacktrace');
      return CommonApiResponse.withError('Error fetching forms config!');
    }
  }

  /// Method to create the params for the forms config API
  createFormsConfigParams(Map<String, int>? versionsMap) {
    /// Get current forms and their versions from the DB
    /// Send map as null if forms don't exist in the DB
    return FormsConfigRequestParams(versionsMap, constants.appId);
  }

  /// API call to submit form data
  Future<CommonApiResponse> submitForm(
      FormSubmissionRequestParams params) async {
    try {
      Map<String, String> tokenHeaders = {
        constants.authorization: 'Bearer ${AppState.instance.jwtTokenString!}',
        constants.accept: constants.headerJson,
        constants.headerContentType: constants.headerJson,
      };
      Response response = await post(
          Uri.parse(constants.baseUrl + constants.formsSubmitEndpoint),
          headers: tokenHeaders,
          body: json.encode(params));
      return CommonApiResponse.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      Util.instance.logMessage('Exception: $error', 'StackTrace: $stacktrace');
      return CommonApiResponse.withError('Error submitting forms!');
    }
  }

  Future<CommonApiResponse> submitFormV2(String appId, String userId,
      List<Map<String, dynamic>> data, String url) async {
    try {
      Map<String, String> tokenHeaders = {
        constants.authorization: 'Bearer ${AppState.instance.jwtTokenString!}',
        constants.accept: constants.headerJson,
        constants.headerContentType: constants.headerJson,
      };

      String body = json.encode(<String, dynamic>{
        'app_uuid': appId,
        'user_id': userId,
        'data': data
      });

      Util.instance.logMessage('SUMMIT ====Request===', body);
      Response response =
          await post(Uri.parse(url), headers: tokenHeaders, body: body);
      Util.instance.logMessage('SUMMIT ====Response===', response.body);

      return CommonApiResponse.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      Util.instance.logMessage('Exception: $error', 'StackTrace: $stacktrace');
      return CommonApiResponse.withError('Error submitting forms!');
    }
  }

  /// Method to create the params for the forms submit API
  createFormsSubmitParams(
      List<EntityInstance> entityInstances, String submissionId) {
    String editedEntity = '';
    return FormSubmissionRequestParams(
        appId: constants.appId,
        username: AppState.instance.userId,
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        submissionId: submissionId,
        entityInstances: entityInstances,
        editedEntity: editedEntity);
  }

  /// API call to fetch form submissions
  Future<CommonApiResponse> fetchSubmissions(
      FetchSubmissionRequestParams params) async {
    try {
      Map<String, String> tokenHeaders = {
        constants.authorization: 'Bearer ${AppState.instance.jwtTokenString!}',
        constants.accept: constants.headerJson,
        constants.headerContentType: constants.headerJson,
      };
      Response response = await post(
          Uri.parse(constants.baseUrl + constants.fetchSubmissionsEndpoint),
          headers: tokenHeaders,
          body: json.encode(params));
      return CommonApiResponse.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      Util.instance.logMessage('Exception: $error', 'StackTrace: $stacktrace');
      return CommonApiResponse.withError('Error fetching form submissions!');
    }
  }

  /// Method to create the params for the fetch form submissions API
  createFetchSubmissionsParams(Map<String, int> submissionIdToTimestamp) {
    return FetchSubmissionRequestParams(
      appId: constants.appId,
      username: AppState.instance.userId,
      eventTimestampMap: submissionIdToTimestamp,
    );
  }

  /// GET API call to fetch form dropdown values
  Future<CommonApiResponse> fetchDropdownValues(String url) async {
    try {
      Map<String, String> tokenHeaders = {
        constants.authorization: 'Bearer ${AppState.instance.jwtTokenString!}',
      };
      Response response = await get(Uri.parse(url), headers: tokenHeaders);
      return CommonApiResponse(
          result: true,
          statusCode: 200,
          statusCodeDescription: "Success",
          message: '',
          response: {'result': json.decode(response.body).toList()});
    } catch (error, stacktrace) {
      Util.instance.logMessage('Exception: $error', 'StackTrace: $stacktrace');
      return CommonApiResponse.withError(
          'Error fetching form dropdown value -- $url');
    }
  }

  /// POST API call to fetch form dropdown values
  Future<CommonApiResponse> fetchDropdownValueUsingPostApi(
      String url, Map<String, dynamic> params) async {
    try {
      Map<String, String> tokenHeaders = {
        constants.authorization: 'Bearer ${AppState.instance.jwtTokenString!}',
        constants.accept: constants.headerJson,
        constants.headerContentType: constants.headerJson,
      };
      Response response = await post(Uri.parse(url),
          headers: tokenHeaders, body: json.encode(params));
      return CommonApiResponse.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      Util.instance.logMessage('Exception: $error', 'StackTrace: $stacktrace');
      return CommonApiResponse.withError(
          'Error fetching form dropdown value -- $url');
    }
  }

  /// POST API call to fetch list of submitted data
  Future<SubmittedDataModel> fetchFetchSubmissionDataList(String url,
      String entityId, String? submissionId, bool relativeEntities) async {
    try {
      Map<String, String> tokenHeaders = {
        constants.authorization: 'Bearer ${AppState.instance.jwtTokenString!}',
        constants.csrf: 'Bearer ${AppState.instance.csrfTokenString!}',
        constants.accept: constants.headerJson,
        constants.headerContentType: constants.headerJson,
      };

      Map<String, dynamic> params = {
        "application_id": constants.appId,
        "entity_id": entityId,
        "submission_id": submissionId,
        "relative_entities": relativeEntities
      };

      Response response = await post(Uri.parse(url),
          headers: tokenHeaders, body: json.encode(params));
      return SubmittedDataModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      Util.instance.logMessage('Exception: $error', 'StackTrace: $stacktrace');
      return SubmittedDataModel.withError('Error data -- $url');
    }
  }

  /// This method is called to get an upload URL for media sync
  Future<String?> getUploadURL(String mediaName, BuildContext context) async {
    String? uploadUrl = '';
    try {
      Map<String, String> tokenHeaders = {
        constants.authorization: 'Bearer ${AppState.instance.jwtTokenString!}',
      };
      Response response = await get(
          Uri.parse(
              constants.baseUrl + constants.getUploadUrlEndpoint + mediaName),
          headers: tokenHeaders);
      if (response.statusCode == 200) {
        CommonApiResponse apiResponse =
            CommonApiResponse.fromJson(jsonDecode(response.body));
        Map<String, dynamic>? responseMap = apiResponse.response;
        uploadUrl = responseMap!['putUrl'];
      } else if (response.statusCode == 401) {
        /// Session expired, redirecting to login screen
        await Util.instance.redirectToLoginBecauseOfTokenExpiry(context);
      }
    } catch (error, stacktrace) {
      Util.instance.logMessage('Exception: $error', 'StackTrace: $stacktrace');
    }
    return uploadUrl;
  }

  createFCMTokenParams(String token, String userName) {
    return SendingFcmTokenModel(
      token: token,
      username: userName,
    );
  }

  /// Calling RefreshToken API
  Future<CommonApiResponse> refreshTokenRequest(
      String accessToken, String refreshToken, String userName) async {
    Map<String, String> tokenHeaders = {
      constants.authorization: accessToken,
      constants.refreshToken: refreshToken,
      constants.userNameHeader: userName
    };
    String refreshTokenUrl =
        constants.authBaseUrl + constants.refreshTokenEndpoint;
    Response response =
        await post(Uri.parse(refreshTokenUrl), headers: tokenHeaders);
    CommonApiResponse authResponse =
        CommonApiResponse.fromJson(jsonDecode(response.body));
    return authResponse;
  }

  createUpdateAppVersionParams(String version) {
    return UpdateAppVersionRequestParams(
        AppState.instance.userId, version, constants.appId);
  }

  Future<CommonApiResponse> csrfTokenRequest(String accessToken) async {
    Map<String, String> tokenHeaders = {
      constants.authorization: 'Bearer $accessToken',
    };
    String csrfTokenUrl = constants.authBaseUrl + constants.csrfTokenEndpoint;
    Response response =
        await get(Uri.parse(csrfTokenUrl), headers: tokenHeaders);
    CommonApiResponse authResponse =
        CommonApiResponse.fromJson(jsonDecode(response.body));
    return authResponse;
  }

  /// API call to update user app version
  Future<CommonApiResponse> updateAppVersion(
      UpdateAppVersionRequestParams params) async {
    try {
      Map<String, String> tokenHeaders = {
        constants.authorization: 'Bearer ${AppState.instance.jwtTokenString!}',
        constants.accept: constants.headerJson,
        constants.headerContentType: constants.headerJson,
      };
      Response response = await post(
          Uri.parse(constants.baseUrl + constants.updateAppVersionEndpoint),
          headers: tokenHeaders,
          body: json.encode(params));
      return CommonApiResponse.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      Util.instance.logMessage('Exception: $error', 'StackTrace: $stacktrace');
      return CommonApiResponse.withError('Error updating app version');
    }
  }

  /// Change password api call
  Future<CommonApiResponse> changePassword(String newPassword) async {
    try {
      Map<String, String> tokenHeaders = {
        constants.authorization: 'Bearer ${AppState.instance.jwtTokenString!}',
        constants.accept: constants.headerJson,
        constants.headerContentType: constants.headerJson,
      };

      String changePasswordUrl =
          constants.authBaseUrl + constants.changePasswordEndpoint;

      Response response = await put(Uri.parse(changePasswordUrl),
          headers: tokenHeaders,
          body: jsonEncode(<String, String>{
            'type': 'password',
            'value': newPassword,
            'userId': AppState.instance.jwtToken.sub!,
            'temporary': false.toString()
          }));

      CommonApiResponse apiResponse =
          CommonApiResponse.fromJson(jsonDecode(response.body));
      return apiResponse;
    } catch (error, stacktrace) {
      Util.instance.logMessage('Exception: $error', 'StackTrace: $stacktrace');
      return CommonApiResponse.withError('Error updating password');
    }
  }

  /// Forgot password api call
  Future<CommonApiResponse> forgotPassword(String username) async {
    try {
      String url =
          '${constants.authBaseUrl}${constants.forgotPasswordEndpoint}/$username';

      Response response = await get(Uri.parse(url));
      CommonApiResponse apiResponse =
          CommonApiResponse.fromJson(jsonDecode(response.body));
      return apiResponse;
    } catch (error, stacktrace) {
      Util.instance.logMessage('Exception: $error', 'StackTrace: $stacktrace');
      return CommonApiResponse.withError(constants.resetPasswordErrorMsg);
    }
  }

  /// Fetch basic theme
  Future<CommonApiResponse> fetchTheme(String appId) async {
    String url =
        '${constants.authBaseUrl}${constants.themeEndpoint}/${constants.appId}';
    Response response = await get(Uri.parse(url));
    CommonApiResponse commonResponse =
        CommonApiResponse.fromJson(jsonDecode(response.body));

    return commonResponse;
  }

  /// Update installation count
  Future<CommonApiResponse> updateInstallationCount(String appId) async {
    try {
      String url = constants.baseUrl + constants.mobileInstallationCountUpdate;

      Response response = await post(Uri.parse(url),
          body: jsonEncode(<String, String>{
            'application_id': appId,
          }));

      debugPrint('$url -- ${response.body}');

      CommonApiResponse apiResponse =
          CommonApiResponse.fromJson(jsonDecode(response.body));
      return apiResponse;
    } catch (error, stacktrace) {
      Util.instance.logMessage('Exception: $error', 'StackTrace: $stacktrace');
      return CommonApiResponse.withError('Error updating password');
    }
  }
}
