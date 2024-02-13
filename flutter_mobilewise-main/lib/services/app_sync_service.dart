import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/utils/image_upload_provider.dart';
import 'package:hive/hive.dart';
import 'package:synchronized/synchronized.dart';

import '../screens/forms/model/fetch_submissions_request_params.dart';
import '../screens/forms/model/fetch_submissions_response.dart';
import '../screens/forms/model/form_media_model.dart';
import '../screens/forms/model/form_submission_request_params.dart';
import '../screens/forms/model/form_submission_response.dart';
import '../screens/forms/model/offline_submission_model.dart';
import '../screens/forms/model/server_form_model.dart';
import '../screens/forms/model/server_submission.dart';
import '../shared/event/app_events.dart';
import '../shared/model/common_api_response.dart';
import '../shared/model/forms_config.dart';
import '../shared/model/forms_config_request_params.dart';
import '../shared/model/framework_form.dart';
import '../shared/model/theme_model.dart';
import '../utils/app_state.dart';
import '../utils/common_constants.dart' as constants;
import '../utils/util.dart';
import '../utils/network_util.dart';
import 'api_provider.dart';
import 'package:image/image.dart' as Img;

class AppBackGroundSyncService {
  static var lock = Lock();
  static bool isSyncInProgress = false;

  execute(BuildContext context) async {
    Util.instance.logMessage('App Sync', 'Start of App Background Sync Thread');

    /// Add a check that if Background thread sync is in progress
    /// Then do not have to run
    await lock.synchronized(() async {
      if (isSyncInProgress) {
        Util.instance.logMessage(
            'App Sync',
            'Another Background Sync thread '
                'is in progress - aborting this call');
        return true;
      }
      isSyncInProgress = true;
      AppState.instance.isSyncInProgress = true;

      bool result = true;

      /// Check if server available
      bool isOnline = await networkUtils.hasActiveInternet();
      if (!isOnline) {
        /// App offline - do not run background sync
        isSyncInProgress = false;
        AppState.instance.isSyncInProgress = false;
        Util.instance.logMessage(
            'App Sync',
            'Cannot initiate the sync '
                'without an active internet connection');
        return false;
      }

      /// Event to mark the start of App Sync
      AppState.instance.eventBus.fire(PreSyncEvent());

      try {
        /// Start Forms Sync
        await startFormsSync(context);

        /// Start Server Submissions Sync
        await startServerSubmissionsSync(context);

        /// Start Offline Submissions Sync
        await startOfflineSubmissionsSync(context);

        /// Form Media Sync
        await formMediaSync(context);

        isSyncInProgress = false;
        AppState.instance.isSyncInProgress = false;
      } on SocketException catch (e) {
        result = false;
        Util.instance.logMessage(
            'App Sync', 'SocketException :: Could not connect to server -- $e');
      } on Exception catch (e) {
        result = false;
        Util.instance.logMessage('App Sync',
            'Exception while background sync was in progress -- stopping sync -- $e');
      } on Error catch (e) {
        result = false;
        Util.instance.logMessage('App Sync',
            'Error occurred while background sync was in progress -- stopping sync -- $e');
      } finally {
        isSyncInProgress = false;
        AppState.instance.isSyncInProgress = false;
      }
      isSyncInProgress = false;
      AppState.instance.isSyncInProgress = false;

      /// Event to mark the end of App Sync
      AppState.instance.eventBus.fire(PostSyncEvent());

      Util.instance.logMessage(
          'App Sync', 'App Background completed. Status -- $result');
      return result;
    });
  }

  /// Syncing forms
  startFormsSync(BuildContext context) async {
    /// Create params for the forms service -
    /// Fetch the list of forms from the DB, along with their latest versions
    /// Make the API call
    /// If forms are received in the response, save them to the app state and the DB

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
      Util.instance.logMessage('App Sync service', 'No cached forms exists');
    }

    if (cachedFormsList != null && cachedFormsList.isNotEmpty) {
      /// Cached forms exist
      Util.instance.logMessage(
          'App Sync service', 'Cached forms exists -- $cachedFormsList');
      for (ServerFormModel form in cachedFormsList) {
        formsVersionMap[form.formKey] = form.version;
      }
      Util.instance.logMessage(
          'App Sync service', 'Cached forms versions -- $formsVersionMap');
    }

    getTheme();
    FormsConfigRequestParams params =
        ApiProvider().createFormsConfigParams(formsVersionMap);
    CommonApiResponse response =
        await ApiProvider().fetchFormsConfig(params, true);
    FormsConfig formsConfig = const FormsConfig(formList: []);
    if (response.statusCode != null && response.statusCode == 200) {
      if (response.response != null && response.response!.isNotEmpty) {
        formsConfig = FormsConfig.fromJson(response.response!);
        if (formsConfig.formList.isNotEmpty) {
          Util.instance.logMessage(
              'App sync service', 'Server has returned forms $formsConfig');

          /// Only the forms with newer versions will be returned
          /// Make sure the older forms from the cache are also added to AppState
          /// Also, update the local cache list of forms
          List<ServerFormModel> newCachedList = [];

          /// Adding the new received form to the AppState
          AppState.instance.formsList.clear();
          for (ServerFormModel form in formsConfig.formList) {
            FrameworkForm f = FrameworkForm.fromJson(jsonDecode(form.formJson));
            AppState.instance.formsList.add(f);
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
          Util.instance.logMessage(
              'App Sync Service', 'No new forms returned by server');
          AppState.instance.formsList.clear();
          if (cachedFormsList != null && cachedFormsList.isNotEmpty) {
            for (ServerFormModel form in cachedFormsList) {
              FrameworkForm f =
                  FrameworkForm.fromJson(jsonDecode(form.formJson));
              AppState.instance.formsList.add(f);
            }
          }
        }
      } else {
        /// No new forms exists
        /// The local DB contains the latest forms
        /// In this case, the existing forms should be loaded from the DB
        Util.instance.logMessage('App Sync Service', 'Invalid response');
        AppState.instance.formsList.clear();
        if (cachedFormsList != null && cachedFormsList.isNotEmpty) {
          for (ServerFormModel form in cachedFormsList) {
            FrameworkForm f = FrameworkForm.fromJson(jsonDecode(form.formJson));
            AppState.instance.formsList.add(f);
          }
        }
      }
    } else if (response.statusCode != null && response.statusCode == 401) {
      /// Session expired, redirecting to login screen
      isSyncInProgress = false;
      AppState.instance.isSyncInProgress = false;

      /// Event to mark the end of App Sync
      AppState.instance.eventBus.fire(PostSyncEvent());
      Util.instance
          .logMessage('App Sync', 'App Background completed. Status -- false');
      await Util.instance.redirectToLoginBecauseOfTokenExpiry(context);
    } else {
      /// Handle error case
      /// Check if forms exists in the local DB
      Util.instance.logMessage('App Sync Service',
          'Error -- Code:${response.statusCode} -- ${response.message}');
      AppState.instance.formsList.clear();
      if (cachedFormsList != null && cachedFormsList.isNotEmpty) {
        for (ServerFormModel form in cachedFormsList) {
          FrameworkForm f = FrameworkForm.fromJson(jsonDecode(form.formJson));
          AppState.instance.formsList.add(f);
        }
      }
    }
  }

  /// Syncing server submissions
  startServerSubmissionsSync(BuildContext context) async {
    var fetchedSubmissionsBox;

    fetchedSubmissionsBox = await Hive.openBox(constants.fetchedSubmissionsBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));

    /// Create map of cachedSubmissionsIds to their synced timestamps
    Map<String, int> submissionIdToTimestamp = {};

    List<dynamic>? cachedServerSubmissionsList;
    FetchSubmissionsResponse? userSubmissions;

    try {
      cachedServerSubmissionsList =
          fetchedSubmissionsBox.get(AppState.instance.userId.toLowerCase());
      if (cachedServerSubmissionsList != null &&
          cachedServerSubmissionsList.isNotEmpty) {
        /// Cached submissions from server exist
        for (ServerSubmission submission in cachedServerSubmissionsList) {
          submissionIdToTimestamp[submission.submissionId] =
              submission.timestamp;
        }
      }

      FetchSubmissionRequestParams params =
          ApiProvider().createFetchSubmissionsParams(submissionIdToTimestamp);
      CommonApiResponse response = await ApiProvider().fetchSubmissions(params);

      if (response.statusCode != null && response.statusCode == 200) {
        userSubmissions = FetchSubmissionsResponse.fromJson(response.response!);

        if (userSubmissions != null &&
            userSubmissions!.submissionList.isNotEmpty) {
          Util.instance.logMessage('App Sync Service',
              'Form submissions fetched successfully -- new submissions returned');

          /// The response will only contain the submissions that were not
          /// cached or have newer data (comparing the server sync timestamp)
          if (cachedServerSubmissionsList != null &&
              cachedServerSubmissionsList.isNotEmpty) {
            for (ServerSubmission cachedServerSubmission
                in cachedServerSubmissionsList) {
              bool hasNewerData = false;
              for (ServerSubmission submission
                  in userSubmissions!.submissionList) {
                if (cachedServerSubmission.submissionId ==
                    submission.submissionId) {
                  hasNewerData = true;
                  break;
                }
              }
              if (!hasNewerData) {
                /// If the cachedServerSubmission does not new data, we need to
                /// add it to the list that will be used to render on screen
                userSubmissions!.submissionList.add(cachedServerSubmission);
              }
            }
          }

          /// Sort the submissions by timestamp
          List<ServerSubmission> sortedSubmissionsList = [];
          sortedSubmissionsList.addAll(
              _sortUserSubmissionsByTimestamp(userSubmissions!.submissionList));

          /// Remove deleted projects
          List<ServerSubmission> tempList = [];
          if (sortedSubmissionsList.isNotEmpty &&
              userSubmissions.deletedSubmissionList.isNotEmpty) {
            tempList.addAll(sortedSubmissionsList);
            for (ServerSubmission submission in tempList) {
              for (String deletedSubmission
                  in userSubmissions.deletedSubmissionList) {
                if (submission.submissionId == deletedSubmission) {
                  sortedSubmissionsList.remove(submission);
                  break;
                }
              }
            }
          }

          /// Update cached server submissions list
          if (cachedServerSubmissionsList != null &&
              cachedServerSubmissionsList.isNotEmpty) {
            fetchedSubmissionsBox
                .get(AppState.instance.userId.toLowerCase())
                .clear();
          }
          fetchedSubmissionsBox.put(
              AppState.instance.userId.toLowerCase(), sortedSubmissionsList);
        } else if (userSubmissions != null &&
            userSubmissions!.deletedSubmissionList.isNotEmpty) {
          /// Deleted submissions are returned
          if (cachedServerSubmissionsList != null &&
              cachedServerSubmissionsList.isNotEmpty) {
            /// Cached submissions from server exist
            /// Remove deleted projects
            List<dynamic> tempList = [];
            tempList.addAll(cachedServerSubmissionsList);
            for (ServerSubmission submission in tempList) {
              for (String deletedSubmission
                  in userSubmissions.deletedSubmissionList) {
                if (submission.submissionId == deletedSubmission) {
                  cachedServerSubmissionsList.remove(submission);
                  break;
                }
              }
            }

            /// Update cached server submissions list
            fetchedSubmissionsBox
                .get(AppState.instance.userId.toLowerCase())
                .clear();
            fetchedSubmissionsBox.put(AppState.instance.userId.toLowerCase(),
                cachedServerSubmissionsList);
          }
        } else {
          Util.instance.logMessage('App Sync Service',
              'Form submissions -- no new submissions returned');
        }
      } else if (response.statusCode != null && response.statusCode == 401) {
        /// Session expired, redirecting to login screen
        isSyncInProgress = false;
        AppState.instance.isSyncInProgress = false;

        /// Event to mark the end of App Sync
        AppState.instance.eventBus.fire(PostSyncEvent());
        Util.instance.logMessage(
            'App Sync', 'App Background completed. Status -- false');
        await Util.instance.redirectToLoginBecauseOfTokenExpiry(context);
      }
    } on Error catch (e) {
      Util.instance.logMessage(
          'App Sync Service', 'Error while fetching form submissions $e');
    }
  }

  /// Sort the submissions by timestamp
  _sortUserSubmissionsByTimestamp(List<ServerSubmission> submissionList) {
    List<ServerSubmission> tempList = [];
    tempList.addAll(submissionList);
    submissionList.clear();
    submissionList.addAll(tempList
      ..sort((a, b) {
        return a.timestamp.compareTo(b.timestamp);
      }));
    submissionList = List.from(submissionList.reversed);
    return submissionList;
  }

  /// Syncing offline submissions
  startOfflineSubmissionsSync(BuildContext context) async {
    var offlineSubmissionsBox = await Hive.openBox(constants.submissionsBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));

    List<dynamic>? offlineSubmissionsList = [];
    offlineSubmissionsList.addAll(
        offlineSubmissionsBox.get(AppState.instance.userId.toLowerCase()) ??
            []);
    if (offlineSubmissionsList.isNotEmpty) {
      /// Offline submissions exist
      Util.instance.logMessage('App Sync service', 'Offline submissions exist');
      for (OfflineSubmissionModel offlineSubmission in offlineSubmissionsList) {
        if (offlineSubmission.submissionId.isEmpty) {
          /// This is a fresh submission, no record of this submission exists on
          /// the backend server
          Util.instance
              .logMessage('App Sync service', 'Fresh submission -- offline');
          FormSubmissionResponse r =
              FormSubmissionResponse(false, constants.genericErrorMsg);
          try {
            FormSubmissionRequestParams params = ApiProvider()
                .createFormsSubmitParams(
                    offlineSubmission.entities, offlineSubmission.submissionId);
            CommonApiResponse response = await ApiProvider().submitForm(params);
            if (response.statusCode != null && response.statusCode == 200) {
              r.isSuccessful = true;
              r.message = response.message!;
            } else if (response.statusCode != null &&
                response.statusCode == 401) {
              /// Session expired, redirecting to login screen
              isSyncInProgress = false;
              AppState.instance.isSyncInProgress = false;

              /// Event to mark the end of App Sync
              AppState.instance.eventBus.fire(PostSyncEvent());
              Util.instance.logMessage(
                  'App Sync', 'App Background completed. Status -- false');
              await Util.instance.redirectToLoginBecauseOfTokenExpiry(context);
            } else {
              r.message = response.message!;
            }
          } on Error catch (e) {
            Util.instance.logMessage('App Sync Service',
                'Error while submitting offline form data $e');
          } finally {
            if (r.isSuccessful) {
              /// Submissions successful
              Util.instance.logMessage(
                  'App Sync Service', 'Offline submission successful');

              /// Remove this project from hive list for offline submissions
              List<dynamic> hiveOfflineSubmissionEntries = [];
              hiveOfflineSubmissionEntries.addAll(offlineSubmissionsBox
                      .get(AppState.instance.userId.toLowerCase()) ??
                  []);
              if (hiveOfflineSubmissionEntries.isNotEmpty) {
                hiveOfflineSubmissionEntries.remove(offlineSubmission);
                offlineSubmissionsBox.put(
                    AppState.instance.userId.toLowerCase(),
                    hiveOfflineSubmissionEntries);
              }

              AppState.instance.eventBus.fire(RefreshSyncCount());

              /// Start Server Submissions Sync
              await startServerSubmissionsSync(context);
            } else {
              /// Submissions unsuccessful
              if (offlineSubmission.retries == constants.maxMediaRetries) {
                /// Remove this project from hive list for offline submissions
                List<dynamic> hiveOfflineSubmissionEntries = [];
                hiveOfflineSubmissionEntries.addAll(offlineSubmissionsBox
                        .get(AppState.instance.userId.toLowerCase()) ??
                    []);
                if (hiveOfflineSubmissionEntries.isNotEmpty) {
                  hiveOfflineSubmissionEntries.remove(offlineSubmission);
                  offlineSubmissionsBox.put(
                      AppState.instance.userId.toLowerCase(),
                      hiveOfflineSubmissionEntries);
                }

                AppState.instance.eventBus.fire(RefreshSyncCount());
              } else {
                Util.instance.logMessage(
                    'App Sync Service', 'Offline submission unsuccessful');

                /// Increase retry attempts and save to hive
                List<dynamic>? sList = [];
                sList.addAll(offlineSubmissionsBox
                    .get(AppState.instance.userId.toLowerCase()));
                for (int i = 0; i < sList.length; i++) {
                  OfflineSubmissionModel os =
                      sList[i] as OfflineSubmissionModel;
                  if (os == offlineSubmission) {
                    os.retries++;
                    sList[i] = os;
                    break;
                  }
                }
                offlineSubmissionsBox
                    .get(AppState.instance.userId.toLowerCase())
                    .clear();
                offlineSubmissionsBox.put(
                    AppState.instance.userId.toLowerCase(), sList);
              }
            }
          }
        } else {
          /// This submission has a transaction history. Before submission API
          /// call, we need to check the server sync ts
          /// If the server sync ts in the offline submission record is same as
          /// that on the backend, we can sync the project
          /// If the server sync ts in the offline submission record is smaller
          /// than the backend, then the data is stale, and we need conflict
          /// resolution before submission. Move this project in the
          /// rejected list of offline submissions
          Util.instance
              .logMessage('App Sync service', 'Stale submission -- offline');
          var fetchedSubmissionsBox = await Hive.openBox(
              constants.fetchedSubmissionsBox,
              encryptionCipher: HiveAesCipher(base64Decode(
                  AppState.instance.hiveEncryptionKey.toString())));

          List<dynamic>? cachedServerSubmissionsList;
          cachedServerSubmissionsList =
              fetchedSubmissionsBox.get(AppState.instance.userId.toLowerCase());

          if (cachedServerSubmissionsList != null &&
              cachedServerSubmissionsList.isNotEmpty) {
            /// Cached submissions from server exist
            for (ServerSubmission submission in cachedServerSubmissionsList) {
              if (submission.submissionId == offlineSubmission.submissionId) {
                if (submission.timestamp == offlineSubmission.serverSyncTs) {
                  Util.instance.logMessage(
                      'App Sync service', 'Stale submission -- submit');

                  /// No new data has been added on the server
                  /// Submit this project
                  FormSubmissionResponse r =
                      FormSubmissionResponse(false, constants.genericErrorMsg);
                  try {
                    FormSubmissionRequestParams params = ApiProvider()
                        .createFormsSubmitParams(offlineSubmission.entities,
                            offlineSubmission.submissionId);
                    CommonApiResponse response =
                        await ApiProvider().submitForm(params);
                    if (response.statusCode != null &&
                        response.statusCode == 200) {
                      r.isSuccessful = true;
                      r.message = response.message!;
                    } else if (response.statusCode != null &&
                        response.statusCode == 401) {
                      /// Session expired, redirecting to login screen
                      isSyncInProgress = false;
                      AppState.instance.isSyncInProgress = false;

                      /// Event to mark the end of App Sync
                      AppState.instance.eventBus.fire(PostSyncEvent());
                      Util.instance.logMessage('App Sync',
                          'App Background completed. Status -- false');
                      await Util.instance
                          .redirectToLoginBecauseOfTokenExpiry(context);
                    } else {
                      r.message = response.message!;
                    }
                  } on Error catch (e) {
                    Util.instance.logMessage('App Sync Service',
                        'Error while submitting offline form data $e');
                  } finally {
                    if (r.isSuccessful) {
                      /// Submissions successful
                      Util.instance.logMessage(
                          'App Sync Service', 'Offline submission successful');

                      /// Remove this project from hive list for offline submissions
                      List<dynamic> hiveOfflineSubmissionEntries = [];
                      hiveOfflineSubmissionEntries.addAll(offlineSubmissionsBox
                              .get(AppState.instance.userId.toLowerCase()) ??
                          []);
                      if (hiveOfflineSubmissionEntries.isNotEmpty) {
                        hiveOfflineSubmissionEntries.remove(offlineSubmission);
                        offlineSubmissionsBox.put(
                            AppState.instance.userId.toLowerCase(),
                            hiveOfflineSubmissionEntries);
                      }

                      AppState.instance.eventBus.fire(RefreshSyncCount());

                      /// Start Server Submissions Sync
                      await startServerSubmissionsSync(context);
                    } else {
                      /// Submissions unsuccessful
                      if (offlineSubmission.retries ==
                          constants.maxMediaRetries) {
                        /// Remove this project from hive list for offline submissions
                        List<dynamic> hiveOfflineSubmissionEntries = [];
                        hiveOfflineSubmissionEntries.addAll(
                            offlineSubmissionsBox.get(
                                    AppState.instance.userId.toLowerCase()) ??
                                []);
                        if (hiveOfflineSubmissionEntries.isNotEmpty) {
                          hiveOfflineSubmissionEntries
                              .remove(offlineSubmission);
                          offlineSubmissionsBox.put(
                              AppState.instance.userId.toLowerCase(),
                              hiveOfflineSubmissionEntries);
                        }

                        AppState.instance.eventBus.fire(RefreshSyncCount());
                      } else {
                        Util.instance.logMessage('App Sync Service',
                            'Offline submission unsuccessful');

                        /// Increase retry attempts and save to hive
                        List<dynamic>? sList = [];
                        sList.addAll(offlineSubmissionsBox
                            .get(AppState.instance.userId.toLowerCase()));
                        for (int i = 0; i < sList.length; i++) {
                          OfflineSubmissionModel os =
                              sList[i] as OfflineSubmissionModel;
                          if (os == offlineSubmission) {
                            os.retries++;
                            sList[i] = os;
                            break;
                          }
                        }
                        offlineSubmissionsBox
                            .get(AppState.instance.userId.toLowerCase())
                            .clear();
                        offlineSubmissionsBox.put(
                            AppState.instance.userId.toLowerCase(), sList);
                      }
                    }
                  }
                } else {
                  /// New data added on backend for this project
                  /// This offline submission is stale
                  /// Conflict resolution is required
                  Util.instance.logMessage(
                      'App Sync service', 'Stale submission -- do not submit');
                  var rejectedSubmissionsBox = await Hive.openBox(
                      constants.rejectedSubmissionsBox,
                      encryptionCipher: HiveAesCipher(base64Decode(
                          AppState.instance.hiveEncryptionKey.toString())));

                  /// Remove this project from hive list for offline submissions
                  List<dynamic> hiveOfflineSubmissionEntries = [];
                  hiveOfflineSubmissionEntries.addAll(offlineSubmissionsBox
                          .get(AppState.instance.userId.toLowerCase()) ??
                      []);
                  if (hiveOfflineSubmissionEntries.isNotEmpty) {
                    hiveOfflineSubmissionEntries.remove(offlineSubmission);
                    offlineSubmissionsBox.put(
                        AppState.instance.userId.toLowerCase(),
                        hiveOfflineSubmissionEntries);
                  }

                  AppState.instance.eventBus.fire(RefreshSyncCount());

                  /// Add to rejected list of submissions
                  List<dynamic>? rList = rejectedSubmissionsBox
                      .get(AppState.instance.userId.toLowerCase());
                  if (rList != null) {
                    rList.add(offlineSubmission);
                    rejectedSubmissionsBox
                        .get(AppState.instance.userId.toLowerCase())
                        .clear();
                    rejectedSubmissionsBox.put(
                        AppState.instance.userId.toLowerCase(), rList);
                  } else {
                    rejectedSubmissionsBox.put(
                        AppState.instance.userId.toLowerCase(),
                        [offlineSubmission]);
                  }
                }
                break;
              }
            }
          }
        }
      }
    } else {
      /// Offline submissions do not exist
      Util.instance
          .logMessage('App Sync service', 'Offline submissions do not exist');
    }
  }

  /// This method is called to sync form media entries to AWS S3
  formMediaSync(BuildContext context) async {
    /// 1. Fetch the media files from the hive box that need to be synced
    /// 2. Fetch pre-signed URL for the image being synced
    /// 3. Sync image to S3 bucket
    /// 4. If successful, remove entry from the hive box and delete file.
    ///    If not successful, update the retries count for the image and
    ///    move to the next image
    /// Opening the form media box
    Box formMediaBox = await Hive.openBox(constants.formMediaBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));
    List<dynamic> hiveMediaEntries = [];
    hiveMediaEntries
        .addAll(formMediaBox.get(AppState.instance.userId.toLowerCase()) ?? []);
    if (hiveMediaEntries.isNotEmpty) {
      /// Hive entries present to be synced
      for (FormMediaModel mediaFileEntry in hiveMediaEntries) {
        File media = File(mediaFileEntry.path);
        if (await media.exists()) {
            /// Upload media to S3
           /* Uint8List fileInBytes;
            fileInBytes = await resizeImage(media.path);*/
            String imageUrl =
                await ImageUploadProvider().uploadMediaToS3(media);
            if (imageUrl.isNotEmpty) {
              /// File was uploaded successfully
              /// Remove media entry from hive box and delete file from storage
              await _removeEntryFromHiveAndDeleteFromStorage(
                  media, mediaFileEntry, formMediaBox);
              Util.instance.logMessage('Media Sync', 'Upload successful');

              /// Event to refresh the sync count
              AppState.instance.eventBus.fire(RefreshSyncCount());
            } else {
              /// File upload failed
              /// Check if retries threshold has reached
              /// If it has, remove the file from hive and delete from local storage
              /// If not, update retries count and updating the hive box
              if (mediaFileEntry.retries + 1 == constants.maxMediaRetries) {
                /// Remove media entry from hive box and delete file from storage
                await _removeEntryFromHiveAndDeleteFromStorage(
                    media, mediaFileEntry, formMediaBox);
                Util.instance.logMessage('Media Sync', 'Max retries reached');

                AppState.instance.eventBus.fire(RefreshSyncCount());
              } else {
                _updateRetriesForHiveEntry(mediaFileEntry, formMediaBox);
                Util.instance.logMessage('Media Sync', 'Upload failed');
              }
            }
        } else {
          await _removeEntryFromHiveAndDeleteFromStorage(
              media, mediaFileEntry, formMediaBox);

          /// Event to refresh the sync count
          AppState.instance.eventBus.fire(RefreshSyncCount());
        }
      }
    } else {
      Util.instance.logMessage('Media Sync', 'No media files to sync');
    }
  }

  /// This method removes a hive entry and deletes the file from local storage
  _removeEntryFromHiveAndDeleteFromStorage(
      File file, FormMediaModel mediaModel, Box formMediaBox) async {
    List<dynamic> hiveMediaEntries = [];
    hiveMediaEntries
        .addAll(formMediaBox.get(AppState.instance.userId.toLowerCase()) ?? []);
    if (hiveMediaEntries.isNotEmpty) {
      hiveMediaEntries.remove(mediaModel);
      formMediaBox.put(
          AppState.instance.userId.toLowerCase(), hiveMediaEntries);

      /// Deleting file from local storage
      if (await file.exists()) {
        file.delete();
      }
    }
  }

  /// This method updates a hive entry by incrementing its retires by 1
  _updateRetriesForHiveEntry(FormMediaModel hiveEntry, Box formMediaBox) {
    List<dynamic> hiveMediaEntries = [];
    hiveMediaEntries
        .addAll(formMediaBox.get(AppState.instance.userId.toLowerCase()) ?? []);
    if (hiveMediaEntries.isNotEmpty) {
      FormMediaModel updatedEntry =
          FormMediaModel(hiveEntry.name, hiveEntry.path, hiveEntry.retries + 1);
      hiveMediaEntries.remove(hiveEntry);
      hiveMediaEntries.add(updatedEntry);
      formMediaBox.put(
          AppState.instance.userId.toLowerCase(), hiveMediaEntries);
    }
  }

  Future<Uint8List> resizeImage(String localPath) async {
    File imageFile = File(localPath);
    var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
    int width = (decodedImage.width / 5).toInt();
    int height = (decodedImage.height / 5).toInt();
    Img.Image? imageTemp = Img.decodeImage(imageFile.readAsBytesSync());
    Img.Image resizedImage =
        Img.copyResize(imageTemp!, width: width, height: height);
    Uint8List bytes = Uint8List.fromList(Img.encodeJpg(resizedImage));
    return bytes;
  }

  getTheme() async {
    /// Update app version on backend
    try {
      CommonApiResponse response =
          await ApiProvider().fetchTheme(constants.appId);

      if (response.statusCode != null &&
          response.statusCode == 200 &&
          response.response != null &&
          response.response!.isNotEmpty) {
        ThemeModel themeModel =
            ThemeModel.fromJson(response.response!['theme']);
        AppState.instance.setTheme(themeModel);
      } else if (response.statusCode != null && response.statusCode == 401) {
        Util.instance.logMessage('Home Repo', 'Error while parsing theme');
      }
    } catch (e) {
      Util.instance.logMessage('Home Repo', 'Error while fetching theme -- $e');
    }
  }
}
