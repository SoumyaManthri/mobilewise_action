import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../screens/forms/model/entity_instance_model.dart';
import '../../../screens/forms/model/fetch_submissions_request_params.dart';
import '../../../screens/forms/model/fetch_submissions_response.dart';
import '../../../screens/forms/model/form_submission_request_params.dart';
import '../../../screens/forms/model/form_submission_response.dart';
import '../../../screens/forms/model/server_submission.dart';
import '../../../screens/forms/view_model/form_view_model.dart';
import '../../../services/api_provider.dart';
import '../../../shared/model/common_api_response.dart';
import '../../../shared/model/form_widget_data.dart';
import '../../../shared/model/forms_config.dart';
import '../../../shared/model/forms_config_request_params.dart';
import '../../../shared/model/framework_form.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/util.dart';
import '../model/server_form_model.dart';
import '../model/submitted_data_model.dart';

/// Abstract class for the home repository
abstract class FormRepository {
  Future<FormSubmissionResponse> submitForm(
      List<EntityInstance> entityInstances,
      String submissionId,
      BuildContext context,
      String buttonKey);

  Future<FormSubmissionResponse> submitFormV2(
      List<EntityInstance> entityInstances,
      String submissionId,
      BuildContext context,
      String buttonKey,
      String url);

  Future<FetchSubmissionsResponse?> fetchSubmissions(
      List<dynamic>? fetchedSubmissions, BuildContext context);

  Future<List<String>> fetchDropdownValues(
      String url, String responseKey, BuildContext context);

  Future<List<String>> fetchDropdownValueUsingPostAPI(
      FormViewModel viewModel,
      String url,
      String responseKey,
      Map<String, String> params,
      String fieldKey,
      BuildContext context);

  Future<List<Submissions>> fetchSubmissionList(String entityId,
      String? submissionId, bool relativeEntities, BuildContext context);

  getForms(BuildContext context);

  getSplashScreenForm();
}

/// Concrete class implementation for the home repository
class FormRepositoryImpl extends FormRepository {
  @override
  Future<FormSubmissionResponse> submitForm(
      List<EntityInstance> entityInstances,
      String submissionId,
      BuildContext context,
      String buttonKey) async {
    FormSubmissionResponse r =
        FormSubmissionResponse(false, constants.genericErrorMsg);
    try {
      FormSubmissionRequestParams params =
          ApiProvider().createFormsSubmitParams(entityInstances, submissionId);
      CommonApiResponse response = await ApiProvider().submitForm(params);
      if (response.statusCode != null && response.statusCode == 200) {
        r.isSuccessful = true;
        r.message = response.message!;
      } else if (response.statusCode != null && response.statusCode == 401) {
        /// Session expired, redirecting to login screen
        await Util.instance.redirectToLoginBecauseOfTokenExpiry(context);
      } else {
        r.message = response.message!;
      }
    } on Error catch (e) {
      Util.instance
          .logMessage('Forms Repo', 'Error while submitting form data $e');
      return r;
    }
    return r;
  }

  @override
  Future<FormSubmissionResponse> submitFormV2(
      List<EntityInstance> entityInstances,
      String submissionId,
      BuildContext context,
      String buttonKey,
      String url) async {
    FormSubmissionResponse r =
        FormSubmissionResponse(false, constants.genericErrorMsg);

    try {
      Map<String, Map<String, dynamic>> data = {};
      AppState.instance.formTempMap.forEach((key, value) {
        Map<String, dynamic> map;
        FormWidgetData widgetData = AppState.instance.formTempWidgetMap[key]!;
        if (data.containsKey(widgetData.entity)) {
          map = data[widgetData.entity]!;
        } else {
          map = <String, dynamic>{'entity_id': widgetData.entity, 'data': []};
          data[widgetData.entity] = map;
        }
        switch (widgetData.field.uiType) {
          case constants.image:
          case constants.filePicker:
            if (value != null && (value as List).isNotEmpty) {
              (map['data'] as List).add(<String, dynamic>{
                'widget_id': widgetData.field.key,
                'widget_label': widgetData.field.label,
                'value': json.encode(value)
              });
            }
            break;
          default:
            (map['data'] as List).add(<String, dynamic>{
              'widget_id': widgetData.field.key,
              'widget_label': widgetData.field.label,
              'value': value.toString()
            });
        }
      });

      CommonApiResponse response = await ApiProvider().submitFormV2(
          constants.appId,
          AppState.instance.jwtToken.sub!,
          data.values.toList(),
          url);
      if (response.statusCode != null && response.statusCode == 200) {
        r.isSuccessful = true;
        r.message = response.message!;
      } else if (response.statusCode != null && response.statusCode == 401) {
        /// Session expired, redirecting to login screen
        await Util.instance.redirectToLoginBecauseOfTokenExpiry(context);
      } else {
        r.message = response.message!;
      }
    } on Error catch (e) {
      if (kDebugMode) {
        print(e.stackTrace);
      }
      Util.instance
          .logMessage('Forms Repo', 'Error while submitting form data $e');
      return r;
    }
    return r;
  }

  @override
  Future<FetchSubmissionsResponse?> fetchSubmissions(
      List<dynamic>? fetchedSubmissions, BuildContext context) async {
    /// Create map of cachedSubmissionsIds to their synced timestamps
    Map<String, int> submissionIdToTimestamp = {};
    FetchSubmissionsResponse? r;

    try {
      if (fetchedSubmissions != null && fetchedSubmissions.isNotEmpty) {
        /// Cached submissions from server exist
        for (ServerSubmission submission in fetchedSubmissions) {
          submissionIdToTimestamp[submission.submissionId] =
              submission.timestamp;
        }
      }

      FetchSubmissionRequestParams params =
          ApiProvider().createFetchSubmissionsParams(submissionIdToTimestamp);
      CommonApiResponse response = await ApiProvider().fetchSubmissions(params);

      if (response.statusCode != null && response.statusCode == 200) {
        r = FetchSubmissionsResponse.fromJson(response.response!);
      } else if (response.statusCode != null && response.statusCode == 401) {
        /// Session expired, redirecting to login screen
        await Util.instance.redirectToLoginBecauseOfTokenExpiry(context);
      }
    } on Error catch (e) {
      Util.instance
          .logMessage('Forms Repo', 'Error while fetching form submissions $e');
      return r;
    }
    return r;
  }

  @override
  Future<List<String>> fetchDropdownValues(
      String url, String responseKey, BuildContext context) async {
    List<String> values = <String>[];
    try {
      CommonApiResponse response = await ApiProvider().fetchDropdownValues(url);
      if (response.statusCode != null &&
          response.statusCode == 200 &&
          response.response != null &&
          response.response!['result'] != null) {
        for (List<dynamic> list in response.response!.values) {
          for (Map<String, dynamic> valueMap in list) {
            for (String key in valueMap.keys) {
              if (key == responseKey) {
                values.add(valueMap[key].toString());
                break;
              }
            }
          }
        }
      } else if (response.statusCode != null && response.statusCode == 401) {
        /// Session expired, redirecting to login screen
        await Util.instance.redirectToLoginBecauseOfTokenExpiry(context);
      }
    } on Error catch (e) {
      Util.instance.logMessage(
          'Forms Repo',
          'Error while fetching dropdown -- $e '
              '-- from URL -> $url');
      return values;
    }
    return values;
  }

  @override
  Future<List<String>> fetchDropdownValueUsingPostAPI(
      FormViewModel viewModel,
      String url,
      String responseKey,
      Map<String, String> params,
      String fieldKey,
      BuildContext context) async {
    List<String> values = <String>[];
    try {
      CommonApiResponse response =
          await ApiProvider().fetchDropdownValueUsingPostApi(url, params);
      if (response.statusCode != null &&
          response.statusCode == 200 &&
          response.response != null &&
          response.response!.isNotEmpty) {
        for (List<dynamic> list in response.response!.values) {
          for (Map<String, dynamic> valueMap in list) {
            for (String key in valueMap.keys) {
              if (key == responseKey) {
                values.add(valueMap[key].toString());
                break;
              }
            }
          }
        }
      } else if (response.statusCode != null && response.statusCode == 401) {
        /// Session expired, redirecting to login screen
        await Util.instance.redirectToLoginBecauseOfTokenExpiry(context);
      }
    } on Error catch (e) {
      Util.instance.logMessage(
          'Forms Repo',
          'Error while fetching dropdown -- $e '
              '-- from URL -> $url');
      return values;
    }
    return values;
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
    Box formsConfigBox;
    formsConfigBox = await Hive.openBox(constants.formsBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));
    List<dynamic>? cachedFormsList;
    try {
      cachedFormsList = formsConfigBox.get(constants.appId.toLowerCase());
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
        await ApiProvider().fetchFormsConfig(params, false);
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
            FrameworkForm f = FrameworkForm.fromJson(jsonDecode(form.formJson));
            AppState.instance.formsList.add(f);
            if (form.formType.isNotEmpty) {
              AppState.instance.formsTypesWithKey[form.formType] = f.formKey;
            }
            newCachedList.add(form);
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
                if (form.formType.isNotEmpty) {
                  AppState.instance.formsTypesWithKey[form.formType] =
                      f.formKey;
                }
                newCachedList.add(form);
              }
            }
          }

          /// Refresh the hive DB
          if (cachedFormsList != null && cachedFormsList.isNotEmpty) {
            formsConfigBox.get(constants.appId.toLowerCase()).clear();
          }
          formsConfigBox.put(constants.appId.toLowerCase(), newCachedList);
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
              if (form.formType.isNotEmpty) {
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
            if (form.formType.isNotEmpty) {
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
          if (form.formType.isNotEmpty) {
            AppState.instance.formsTypesWithKey[form.formType] = f.formKey;
          }
        }
      }
    }
  }

  @override
  getSplashScreenForm() async {
    /// Hive box that stores forms received from server
    Box formsConfigBox;
    formsConfigBox = await Hive.openBox(constants.formsBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));
    List<dynamic>? cachedFormsList;
    try {
      cachedFormsList = formsConfigBox.get(constants.appId.toLowerCase());
    } catch (e) {
      Util.instance.logMessage('Home Repo', 'No cached forms exists');
    }
    if (cachedFormsList != null && cachedFormsList.isNotEmpty) {
      for (ServerFormModel form in cachedFormsList) {
        FrameworkForm f = FrameworkForm.fromJson(jsonDecode(form.formJson));
        AppState.instance.formsList.add(f);
        if (form.formType.isNotEmpty) {
          AppState.instance.formsTypesWithKey[form.formType] = f.formKey;
        }
      }
    }
  }

  @override
  Future<List<Submissions>> fetchSubmissionList(String entityId,
      String? submissionId, bool relativeEntities, BuildContext context) async {
    String url = constants.baseUrl + constants.entitySubmissionListEndPoint;
    try {
      SubmittedDataModel response = await ApiProvider()
          .fetchFetchSubmissionDataList(
              url, entityId, submissionId, relativeEntities);
      if (response.statuscode != null &&
          response.statuscode == 200 &&
          response.submissions != null &&
          response.submissions!.isNotEmpty) {
        for (var item in response.submissions!) {
          Map<String, EntityValuesJson>? map = {
            for (var field in item.entityValuesJson!) '${field.widgetId}': field
          };
          for (var child in item.childEntities ?? []) {
            Map<String, EntityValuesJson>? childMap = {
              for (var childField in child.entityValuesJson!)
                '${childField.widgetId}': childField
            };

            map.addAll(childMap);
          }

          item.dataMap = map;
        }
      } else if (response.statuscode != null && response.statuscode == 401) {
        /// Session expired, redirecting to login screen
        await Util.instance.redirectToLoginBecauseOfTokenExpiry(context);
      }

      response.submissions ??= <Submissions>[];

      return response.submissions!;
    } on Error catch (e) {
      Util.instance.logMessage(
          'Forms Repo',
          'Error while fetching data list data -- $e '
              '-- from URL -> $url');
      return <Submissions>[];
    }
  }
}
