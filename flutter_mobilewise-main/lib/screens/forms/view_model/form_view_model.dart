import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../screens/forms/model/entity_instance_model.dart';
import '../../../screens/forms/model/fetch_submissions_response.dart';
import '../../../screens/forms/model/form_image_field_widget_media.dart';
import '../../../screens/forms/model/form_media_model.dart';
import '../../../screens/forms/model/form_submission_response.dart';
import '../../../screens/forms/model/offline_submission_model.dart';
import '../../../screens/forms/model/server_submission.dart';
import '../../../screens/forms/model/submission_field_model.dart';
import '../../../screens/forms/repository/form_repo.dart';
import '../../../screens/forms/view/form_field_views/form_preview_field_widget.dart';
import '../../../services/api_provider.dart';
import '../../../services/app_sync_service.dart';
import '../../../shared/model/common_api_response.dart';
import '../../../shared/model/framework_form.dart';
import '../../../shared/model/theme_model.dart';
import '../../../shared/view_model/loading_view_model.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/dialog_builder.dart';
import '../../../utils/form_renderer_util.dart';
import '../../../utils/hex_color.dart';
import '../../../utils/image_upload_provider.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/network_util.dart';
import '../../../utils/shared_preference_util.dart';
import '../../../utils/util.dart';
import '../../../utils/validation_util.dart';
import '../../home/view/app_bar_sync_icon_view.dart';
import '../../home/view_model/home_view_model.dart';
import '../../login/model/login_response_model.dart';
import '../../login/repository/login_repo.dart';
import '../model/submitted_data_model.dart';
import '../view/scanning_view.dart';

class FormViewModel extends LoadingViewModel {
  FormViewModel({required this.repo, required this.loginRepo});

  final FormRepository repo;
  final LoginRepository loginRepo;
  late BuildContext buildContext;

  late String formId;

  /// List of all the sub-forms
  late FrameworkForms formsList;

  /// To store the validation error field label and the error message
  Map<String, String> errorWidgetMap = {};

  /// Current sub-form visible to the user
  FrameworkForm currentForm = emptyFormData();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  /// Backstack to handle fragments rendered within the form screen
  List<FrameworkForm> backstack = <FrameworkForm>[];

  /// Submission object for the form
  List<EntityInstance> entityInstances = <EntityInstance>[];

  /// User submissions fetched from the server
  FetchSubmissionsResponse? userSubmissions;

  /// User submissions fetched from the server
  Map<String, ServerSubmission> submissionIdToSubmissionMap = {};

  /// Filtered projects
  List<ServerSubmission> filteredSubmissions = <ServerSubmission>[];

  /// Flag to show if filter is applied
  bool isFilterApplied = false;

  /// This map is initialized after user submissions are fetched
  /// The key is the submissionID
  /// The value is a map of field keys to field values (user submitted)
  Map<String, Map<String, dynamic>> userSubmissionsValuesMap = {};

  /// Id of the submission that the user has clicked on in the data list
  String clickedSubmissionId = '';

  /// Timestamp of the submission that the user has clicked on in the data list
  int clickedSubmissionTs = 0;

  /// This map is initialized whenever a user clicks on an item from the data list
  /// widget. It stores all the information that belongs to that particular
  /// submission (item)
  Map<String, dynamic> clickedSubmissionValuesMap = {};

  /// This map stores values of all the dropdowns by their key
  /// It contains values mentioned in the JSON form
  /// It contains values from GET APIs
  Map<String, List<String>> dropdownValues = {};

  /// This map stores image form fields by their key
  Map<String, FrameworkFormField> imageFields = {};

  /// This map stores date picker form fields by their key
  Map<String, FrameworkFormField> datePickerFields = {};

  /// This map stores file picker form fields by their key
  Map<String, FrameworkFormField> filePickerFields = {};

  late ScrollController scrollController;

  bool scrolledToFirstErrorWidget = false;

  Map<String, bool> dropDownValuesLoaded = {};

  /// This map is used to render the order parts widget (to get the number of items)
  List<Map<String, dynamic>> orderPartItems = [];

  Set<String> dropdownNotLoadedCompletely = {};

  Map<String, dynamic> tempClickedSubmissionsMap = {};
  Submissions? dataListSelected;

  /// Saving the scroll controller instance to scroll up the forms screen.
  setScrollController(ScrollController scrollController) {
    this.scrollController = scrollController;
  }

  ScrollController getScrollController() {
    return scrollController;
  }

  initializeForm() {
    /// Fetching the current user location
    checkCurrentUserLocation();
    List<FrameworkForm> forms = [];
    forms.addAll(AppState.instance.formsList);
    formsList = FrameworkForms(initialFormKey: formId, forms: forms);
  }

  checkCurrentUserLocation() async {
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
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await AppState.instance.location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    /// Tracking the current user location
    AppState.instance.startTrackingUserLocation();
  }

  findCurrentForm(String key) {
    if (formsList.forms.isNotEmpty && key.isNotEmpty) {
      for (FrameworkForm form in formsList.forms) {
        if (form.formKey == key) {
          currentForm = form;
          backstack.add(currentForm);
          break;
        }
      }
    }
  }

  /// This method searches for a form based on the key passed, and returns
  findFormByKey(String key) {
    FrameworkForm f = emptyFormData();
    if (formsList.forms.isNotEmpty && key.isNotEmpty) {
      for (FrameworkForm form in formsList.forms) {
        if (form.formKey == key) {
          f = form;
        }
      }
    }
    return f;
  }

  /// Callback for button interactions from the horizontal bar at the bottom of the screen
  buttonPressed(String key, BuildContext context) async {
    if (currentForm.buttons.isNotEmpty) {
      for (FrameworkFormButton button in currentForm.buttons) {
        if (button.key == key) {
          switch (button.type) {
            case 0:

              /// Cancel button
              onBackPressed(context);
              break;

            case 1:

              /// Next button
              /// 1. Validate current form
              /// 2. Check for decision node conditions, and move to the next form (subform)
              errorWidgetMap =
                  ValidationUtil.instance.validateForm(this, currentForm);
              if (errorWidgetMap.isEmpty) {
                nextButtonPressed(button.decisionNode, context);
              } else {
                /// Validation failed, show error message fields
                scrolledToFirstErrorWidget = false;
                notifyListeners();
              }
              break;

            case 2:

              /// Submit button
              /// Clear temp and submission map for the next form session
              errorWidgetMap =
                  ValidationUtil.instance.validateForm(this, currentForm);
              if (errorWidgetMap.isEmpty) {
                await _submitForm(context, button);
              } else {
                /// Validation failed, show error message on fields
                scrolledToFirstErrorWidget = false;
                notifyListeners();
              }
              break;

            case 3:

              /// Filter button
              /// Validate form
              /// Check if user has entered any filtering params
              errorWidgetMap =
                  ValidationUtil.instance.validateForm(this, currentForm);
              if (errorWidgetMap.isEmpty) {
                bool canFilter = _checkIfFilteringCriteriaEntered();
                if (canFilter) {
                  isFilterApplied = true;
                  _filterSubmissions();
                  onBackPressed(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(constants.emptyFilterErrorMsg),
                  ));
                }
              } else {
                /// Validation failed, show error message on fields
                scrolledToFirstErrorWidget = false;
                notifyListeners();
              }
              break;
          }
        }
      }
    }
  }

  /// This method calls the API to submit the form from the forms repository
  _submitForm(BuildContext context, FrameworkFormButton button) async {
    _submitForm(context, button);
  }

  _submitFormKey(BuildContext context, String buttonKey, String url) async {
    /// 1. Create entity instances
    /// 2. Check if there is an active internet connection
    /// 3. If there is, then submit project in online mode
    /// 4. If there isn't, then add to Hive entries

    bool createdEntityInstances = false;
    buildContext = context;

    /// Showing screen loader
    isLoading = true;
    try {
      createdEntityInstances = await createFormSubmission(context);
      if (createdEntityInstances) {
        /// Entity instances created
        /// Checking for active internet connection
        if (await networkUtils.hasActiveInternet()) {
          /// Active internet connection available
          FormSubmissionResponse response =
              FormSubmissionResponse(false, constants.genericErrorMsg);
          if (AppState.instance.formTempMap.isNotEmpty) {
            /// This project has been submitted before
            response = await repo.submitFormV2(
                entityInstances, clickedSubmissionId, context, buttonKey, url);
          } else {
            /// Passing empty submissionId as this project has not been submitted before
            /// Passing empty buttonKey as this project has not been submitted before
            response = await repo.submitForm(entityInstances, '', context, '');
          }
          isLoading = false;
          if (response.isSuccessful) {
            // clearFormMaps();
            // NavigationUtil.instance
            //     .navigateToFormSubmittedScreen(context, constants.success);
            return true;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(response.message),
            ));
          }
        } else {
          /// Active internet connection not available
          String subId = '';
          int subTs = 0;
          List<EntityInstance> entities = [];
          entities.addAll(entityInstances);
          if (clickedSubmissionValuesMap.isNotEmpty) {
            /// This project has been submitted before
            subId = clickedSubmissionId;
            subTs = clickedSubmissionTs;
          }

          /// Creating an offline submission
          OfflineSubmissionModel offlineSubmission =
              OfflineSubmissionModel(subId, subTs, entities, 0, buttonKey);

          /// Opening Hive box with offline submissions
          var offlineSubmissionsBox = await Hive.openBox(
              constants.submissionsBox,
              encryptionCipher: HiveAesCipher(base64Decode(
                  AppState.instance.hiveEncryptionKey.toString())));
          List<dynamic>? offlineSubmissionsList =
              offlineSubmissionsBox.get(AppState.instance.userId.toLowerCase());

          if (offlineSubmissionsList != null &&
              offlineSubmissionsList.isNotEmpty) {
            /// Offline submissions have been done before
            offlineSubmissionsList.add(offlineSubmission);
            offlineSubmissionsBox.put(
                AppState.instance.userId.toLowerCase(), offlineSubmissionsList);
          } else {
            offlineSubmissionsBox.put(
                AppState.instance.userId.toLowerCase(), [offlineSubmission]);
          }

          isLoading = false;
          clearFormMaps();
          NavigationUtil.instance
              .navigateToFormSubmittedScreen(context, constants.offlineSuccess);
        }
      } else {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.formErrorMsg),
        ));
      }
    } catch (e) {
      debugPrintStack();
      isLoading = false;
      Util.instance
          .logMessage('Form View Model', 'Error while submitting forms $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.genericErrorMsg),
      ));
    }
  }

  /// This method calls the API to fetch the user submissions
  fetchSubmissions(BuildContext context) async {
    /// Checking for active internet connection
    /// If internet connection exists, fetch submissions from server
    /// To fetch submissions create a map of cached submission ids to their
    /// sync timestamps (Empty map will return all submissions)
    /// Only submissions that have newer data will be returned
    /// If internet connection does not exist, show cached submissions

    var fetchedSubmissionsBox;

    fetchedSubmissionsBox = await Hive.openBox(constants.fetchedSubmissionsBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));

    List<dynamic>? cachedServerSubmissionsList;
    try {
      cachedServerSubmissionsList =
          fetchedSubmissionsBox.get(AppState.instance.userId.toLowerCase());
    } catch (e) {
      Util.instance
          .logMessage('Form View Model', 'Error fetching cached submissions');
    }

    isLoading = true;
    if (await networkUtils.hasActiveInternet()) {
      try {
        userSubmissions =
            await repo.fetchSubmissions(cachedServerSubmissionsList, context);
        if (userSubmissions != null &&
            userSubmissions!.submissionList.isNotEmpty) {
          Util.instance.logMessage('Form View Model',
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
          _sortUserSubmissionsByTimestamp();

          /// Remove deleted projects
          List<ServerSubmission> tempList = [];
          if (userSubmissions!.submissionList.isNotEmpty &&
              userSubmissions!.deletedSubmissionList.isNotEmpty) {
            tempList.addAll(userSubmissions!.submissionList);
            for (ServerSubmission submission in tempList) {
              for (String deletedSubmission
                  in userSubmissions!.deletedSubmissionList) {
                if (submission.submissionId == deletedSubmission) {
                  userSubmissions!.submissionList.remove(submission);
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
          fetchedSubmissionsBox.put(AppState.instance.userId.toLowerCase(),
              userSubmissions!.submissionList);

          /// Initialize userSubmissionsValuesMap
          _initUserSubmissionsValuesMap();

          isLoading = false;
        } else {
          Util.instance.logMessage('Form View Model',
              'Error while fetching form submissions OR no new submissions exist on server');

          /// Check for cached server submissions
          if (cachedServerSubmissionsList != null &&
              cachedServerSubmissionsList.isNotEmpty) {
            /// Cached server submissions exist
            Util.instance.logMessage(
                'Form View Model', 'Cached server submissions exist');
            List<ServerSubmission> submissions = [];
            for (ServerSubmission submission in cachedServerSubmissionsList) {
              submissions.add(submission);
            }

            userSubmissions!.submissionList = [];
            userSubmissions!.submissionList.addAll(submissions);

            /// Remove deleted projects
            List<ServerSubmission> tempList = [];
            if (userSubmissions!.deletedSubmissionList.isNotEmpty) {
              tempList.addAll(userSubmissions!.submissionList);
              for (ServerSubmission submission in tempList) {
                for (String deletedSubmission
                    in userSubmissions!.deletedSubmissionList) {
                  if (submission.submissionId == deletedSubmission) {
                    userSubmissions!.submissionList.remove(submission);
                    break;
                  }
                }
              }
            }

            /// Update cached server submissions list
            fetchedSubmissionsBox
                .get(AppState.instance.userId.toLowerCase())
                .clear();
            fetchedSubmissionsBox.put(AppState.instance.userId.toLowerCase(),
                userSubmissions!.submissionList);

            /// Initialize userSubmissionsValuesMap
            _initUserSubmissionsValuesMap();

            isLoading = false;
          } else {
            Util.instance.logMessage(
                'Form View Model', 'Error while fetching form submissions');
            isLoading = false;
          }
        }
      } catch (e) {
        Util.instance.logMessage(
            'Form View Model', 'Error while fetching form submissions $e');

        /// Check for cached server submissions
        if (cachedServerSubmissionsList != null &&
            cachedServerSubmissionsList.isNotEmpty) {
          /// Cached server submissions exist
          Util.instance
              .logMessage('Form View Model', 'Cached server submissions exist');
          List<ServerSubmission> submissions = [];
          for (ServerSubmission submission in cachedServerSubmissionsList) {
            submissions.add(submission);
          }
          userSubmissions = FetchSubmissionsResponse(
              submissionList: [], deletedSubmissionList: []);
          userSubmissions!.submissionList.addAll(submissions);

          /// Initialize userSubmissionsValuesMap
          _initUserSubmissionsValuesMap();

          isLoading = false;
        } else {
          Util.instance.logMessage(
              'Form View Model', 'Error while fetching form submissions');
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(constants.genericErrorMsg),
          ));
        }
      }
    } else {
      /// Check for cached server submissions
      if (cachedServerSubmissionsList != null &&
          cachedServerSubmissionsList.isNotEmpty) {
        /// Cached server submissions exist
        Util.instance
            .logMessage('Form View Model', 'Cached server submissions exist');
        List<ServerSubmission> submissions = [];
        for (ServerSubmission submission in cachedServerSubmissionsList) {
          submissions.add(submission);
        }
        userSubmissions = FetchSubmissionsResponse(
            submissionList: [], deletedSubmissionList: []);
        userSubmissions!.submissionList.addAll(submissions);

        /// Initialize userSubmissionsValuesMap
        _initUserSubmissionsValuesMap();

        isLoading = false;
      } else {
        Util.instance.logMessage('Form View Model',
            'Error while fetching form submissions - No internet connection');
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.noNetworkAvailability),
        ));
      }
    }
  }

  _getValueForKey(String key, String submissionId) {
    dynamic value;
    if (userSubmissionsValuesMap.containsKey(submissionId)) {
      Map<String, dynamic> valuesMap =
          userSubmissionsValuesMap[submissionId] as Map<String, dynamic>;
      if (valuesMap.containsKey(key)) {
        value = valuesMap[key];
      }
    }
    return value;
  }

  /// Sorts the submissions by timestamp
  _sortUserSubmissionsByTimestamp() {
    List<ServerSubmission> tempList = [];
    tempList.addAll(userSubmissions!.submissionList);
    userSubmissions!.submissionList.clear();
    userSubmissions!.submissionList.addAll(tempList
      ..sort((a, b) {
        return a.timestamp.compareTo(b.timestamp);
      }));
    userSubmissions!.submissionList =
        List.from(userSubmissions!.submissionList.reversed);
  }

  /// This method is called to check if the user has entered any filtering criteria
  _checkIfFilteringCriteriaEntered() {
    bool isEntered = false;
    for (FrameworkFormField field in currentForm.fields) {
      if (AppState.instance.formTempMap.containsKey(field.key)) {
        isEntered = true;
        break;
      }
    }
    return isEntered;
  }

  /// This function is called when filer form is submitted on a data list
  _filterSubmissions() {
    filteredSubmissions.clear();

    if (userSubmissions != null && userSubmissions!.submissionList.isNotEmpty) {
      isLoading = true;

      /// Check if 'Sort By' has been selected - filteredSubmissions is edited
      if (AppState.instance.formTempMap.containsKey(constants.sortByFilter)) {
        /// User has selected a sorting option
        if (AppState.instance.formTempMap[constants.sortByFilter] ==
            constants.sortByCustomer) {
          /// Sort by customer name
          _sortSubmissionsByCustomerName();
        } else if (AppState.instance.formTempMap[constants.sortByFilter] ==
            constants.sortByDate) {
          /// Sort by date of submission of event
          _sortFilteredSubmissionsByDate();
        }
      }

      /// Check if the user has entered the 'Date Range'
      if (AppState.instance.formTempMap
          .containsKey(constants.dateRangeFilter)) {
        /// User has entered a date range
        String range = AppState.instance.formTempMap[constants.dateRangeFilter];
        List<String> startEndString = range.split('#');

        /// Setting the end date to the start of the following day so that any
        /// submissions made on that end date are also returned
        startEndString[1] =
            startEndString[1].replaceAll("00:00:00.000", "24:00:00.000");
        int start = DateTime.parse(startEndString[0]).millisecondsSinceEpoch;
        int end = DateTime.parse(startEndString[1]).millisecondsSinceEpoch;
        if (filteredSubmissions.isEmpty) {
          /// Sorting by 'Customer Name' or 'Date' was not selected
          /// filteredSubmissions contains the sorted submissions
          List<ServerSubmission> tempList = <ServerSubmission>[];
          tempList.addAll(userSubmissions!.submissionList);
          for (ServerSubmission submission in tempList) {
            if (submission.reportedTs >= start &&
                submission.reportedTs <= end) {
              filteredSubmissions.add(submission);
            }
          }
        } else {
          /// Sorting by 'Customer Name' or 'Date' was selected
          List<ServerSubmission> tempList = <ServerSubmission>[];
          tempList.addAll(filteredSubmissions);
          for (ServerSubmission submission in tempList) {
            if (submission.reportedTs < start || submission.reportedTs > end) {
              filteredSubmissions.remove(submission);
            }
          }
        }
      }

      /// Create a map of the filtered form keys and its values (without 'Sort By' and 'Date Range')
      Map<String, dynamic> filterKeysToValuesMap = {};
      for (FrameworkFormField field in currentForm.fields) {
        /// Ignoring 'Sort By' and 'Date Range' filters
        if (field.key != constants.sortByFilter &&
            field.key != constants.dateRangeFilter) {
          if (AppState.instance.formTempMap.containsKey(field.key)) {
            String key = field.key;
            List<String> keyList = key.split('#');
            dynamic value = AppState.instance.formTempMap[field.key];
            if (keyList.length == 2) {
              filterKeysToValuesMap[keyList[1]] = value;
            }
          }
        }
      }

      if (filterKeysToValuesMap.isNotEmpty) {
        /// Use the filterKeysToValuesMap to create list of filtered projects
        List<String> filteredSubmissionIds = <String>[];
        for (String projectId in userSubmissionsValuesMap.keys) {
          Map<String, dynamic> valuesMap =
              userSubmissionsValuesMap[projectId] as Map<String, dynamic>;
          bool isValid = true;
          for (String key in filterKeysToValuesMap.keys) {
            dynamic value = filterKeysToValuesMap[key] as String;
            if (value.isNotEmpty) {
              if (!valuesMap.containsValue(value.toString())) {
                isValid = false;
                break;
              }
            }
          }
          if (isValid) {
            /// This project qualifies for the filter criteria
            filteredSubmissionIds.add(projectId);
          }
        }

        if (filteredSubmissions.isEmpty) {
          /// 'Sort By' or 'Date Range' was not selected
          for (String submissionId in filteredSubmissionIds) {
            filteredSubmissions.add(
                submissionIdToSubmissionMap[submissionId] as ServerSubmission);
          }
        } else {
          /// 'Sort By' or 'Date Range' was selected
          /// From the filterSubmissions list remove any submissions that are
          /// not present in the filteredSubmissionIds list
          List<ServerSubmission> tempList = <ServerSubmission>[];
          for (ServerSubmission submission in filteredSubmissions) {
            if (filteredSubmissionIds.contains(submission.submissionId)) {
              tempList.add(submission);
            }
          }
          filteredSubmissions.clear();
          filteredSubmissions.addAll(tempList);
        }
      }

      isLoading = false;
      notifyListeners();
    }
  }

  /// This method is called to sort the filtered submissions by customer name
  _sortSubmissionsByCustomerName() {
    filteredSubmissions.clear();
    Map<String, String> submissionIdToCustomerMap = {};
    for (String submissionId in userSubmissionsValuesMap.keys) {
      if (userSubmissionsValuesMap[submissionId]!
          .containsKey(constants.customerKey)) {
        submissionIdToCustomerMap[submissionId] =
            userSubmissionsValuesMap[submissionId]![constants.customerKey];
      }
    }

    /// Sorting the maps values
    var sortedSubmissions = submissionIdToCustomerMap.entries.toList()
      ..sort((a, b) {
        String v1 = a.value;
        String v2 = b.value;
        return v1.compareTo(v2);
      });

    /// Changing list of sorted entries to map
    Map<String, String> sortedSubmissionIdToCustomerMap = {
      for (var v in sortedSubmissions) v.key: v.value
    };

    /// Creating the filtered submissions list in the sorted order
    for (String submissionId in sortedSubmissionIdToCustomerMap.keys) {
      for (ServerSubmission submission in userSubmissions!.submissionList) {
        if (submissionId == submission.submissionId) {
          filteredSubmissions.add(submission);
          break;
        }
      }
    }
  }

  /// This method is called to sort the filtered submissions by date
  _sortFilteredSubmissionsByDate() {
    filteredSubmissions.clear();
    filteredSubmissions.addAll(userSubmissions!.submissionList
      ..sort((a, b) {
        return a.timestamp.compareTo(b.timestamp);
      }));
    filteredSubmissions = List.from(filteredSubmissions.reversed);
  }

  /// Maps are initialized when user submissions are fetched
  _initUserSubmissionsValuesMap() {
    userSubmissionsValuesMap.clear();
    submissionIdToSubmissionMap.clear();
    try {
      for (ServerSubmission submission in userSubmissions!.submissionList) {
        submissionIdToSubmissionMap[submission.submissionId] = submission;
        userSubmissionsValuesMap[submission.submissionId] = {};
        Map<String, dynamic> valuesMap = {};
        for (String entityString in submission.entities) {
          Map<String, dynamic> entityJson = jsonDecode(entityString);
          EntityInstance entity = EntityInstance.fromJson(entityJson);
          for (SubmissionField field in entity.submissionField) {
            valuesMap[field.key] = field.value;
          }
        }
        userSubmissionsValuesMap[submission.submissionId] = valuesMap;
      }
    } catch (e) {
      Util.instance.logMessage(
          'Forms View Model', 'Error while parsing entity instances $e');
    }
  }

  /// This method is called when the user clicks on any project from the data list
  /// widget. It is used to populate the fields of the form for that submission
  initClickedSubmissionValuesMap(String submissionId) {
    clickedSubmissionValuesMap.clear();
    clickedSubmissionValuesMap
        .addAll(userSubmissionsValuesMap[submissionId] as Map<String, dynamic>);
  }

  /// Callback for button interactions from the form fields
  fieldButtonPressed(FrameworkFormField button, BuildContext context,
      bool isValidationrequired, String label) async {
    if (button.label.toLowerCase().contains('forgot password')) {
      NavigationUtil.instance.navigateToForgotPasswordScreen(context);
      return;
    } else if (button.label.toLowerCase().contains('change password')) {
      NavigationUtil.instance.navigateToChangePasswordScreen(context);
      return;
    } else if (button.label.toLowerCase().contains('logout')) {
      Provider.of<HomeViewModel>(context, listen: false).logOut(context);
      return;
    }

    switch (button.type) {
      case 1:

        /// Next button
        /// Check for decision node conditions, and move to the next form (subform)
        if (isValidationrequired) {
          errorWidgetMap =
              ValidationUtil.instance.validateForm(this, currentForm);
          if (errorWidgetMap.isEmpty) {
            //todo uncomment resolve issue
            // scrollController.jumpTo(0.0);
            nextButtonPressed(button.decisionNode, context);
          } else {
            //todo uncomment resolve issue
            /// Validation failed, show error message on fields
            scrolledToFirstErrorWidget = false;
            notifyListeners();
          }
        } else {
          //todo uncomment resolve issue
          //  scrollController.jumpTo(0.0);
          nextButtonPressed(button.decisionNode, context);
        }
        break;

      case 2:

        /// Submit button
        /// Clear temp and submission map for the next form session
        errorWidgetMap =
            ValidationUtil.instance.validateForm(this, currentForm);
        if (errorWidgetMap.isNotEmpty) {
          /// Validation failed, show error message on fields
          scrolledToFirstErrorWidget = false;
          notifyListeners();
          return;
        }

        String url =
            constants.baseUrl + constants.entitySubmissionCreateEndPoint;

        if (currentForm.formType.isNotEmpty &&
            currentForm.formType == constants.loginPage) {
          await _login(context, button.valuesApi.url);
        } else {
          //If preview status is true then we are showing preview screen else direct submission
          if (button.valuesApi.isPreview) {
            var formPreview = emptyFormData();
            formPreview.formType = constants.previewScreenPage;
            backstack.add(formPreview);

            NavigationUtil.instance
                .navigateToFormPreviewScreen(context, button);
          } else {
            bool isSuccess = await _submitFormKey(context, button.key, url);
            if (isSuccess) {
              clearFormMaps();
              nextButtonPressed(button.decisionNode, context);
            }
          }
        }
        break;

      default:

        /// Cancel button
        onBackPressed(context);
        break;
    }
  }

  _login(BuildContext context, String url) async {
    String userName = '';
    String password = '';
    int position = 0;
    AppState.instance.formTempMap.forEach((key, value) {
      if (position == 0) {
        userName = value;
      } else {
        password = value;
      }
      position = position + 1;
    });
    String auth64Password = await encryptPassword(userName, password, context);
    await authenticate(userName, auth64Password, context, url);
  }

  Future<String> encryptPassword(
      String userId, String password, BuildContext context) async {
    /// Converting username and password to base64 by combining
    String userNamePasswordBase64 =
        await Util.instance.getConvertedBase64String('$userId:$password');
    String auth64 = 'Basic $userNamePasswordBase64';
    return auth64;
  }

  Future<void> authenticate(String userId, String passwordBase64,
      BuildContext context, String url) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      if (!await restrictLoginAttempts()) {
        late LoginResponseModel loginResponse;
        // isLoading = true;
        try {
          showLoaderDialog(context);
          loginResponse =
              await loginRepo.authenticate(userId, passwordBase64, context);
        } catch (e) {
          Navigator.pop(context);
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
          Navigator.pop(context);
          AppState.instance.formTempMap.clear();
          backstack.remove(currentForm);
          NavigationUtil.instance.navigateToHomeScreen(context, true);
        } else {
          Navigator.pop(context);

          /// Login is unsuccessful
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(loginResponse.message),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.toManyLoginAttempts),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
              color: HexColor(AppState.instance.themeModel.primaryColor)),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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
          constants.preferenceLoginAttempts,
          attempts,
          constants.preferenceTypeInt);
    }
    attempts = attempts + 1;
    if (attempts >= constants.lockOutAttempts &&
        timeDiff <= constants.lockOutTime) {
      return true;
    }
    await SharedPreferenceUtil.instance.setPreferenceValue(
        constants.preferenceLoginAttempts,
        attempts,
        constants.preferenceTypeInt);
    await SharedPreferenceUtil.instance.setPreferenceValue(
        constants.preferenceLastLoginTime,
        double.parse(DateTime.now().millisecondsSinceEpoch.toString()),
        constants.preferenceTypeDouble);
    return false;
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
      // isLoading = false;
      notifyListeners();
    } else {
      Util.instance.logMessage('Home View Model',
          'Error while fetching screen config - No internet connection');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
  }

  /// Check decision nodes for buttons and move to the next sub-form accordingly
  nextButtonPressed(DecisionNode decisionNode, BuildContext context) {
    String subform = '';
    if (decisionNode.sources.isNotEmpty) {
      String values = '';

      if (decisionNode.sources.length == 2) {
        Set<String> indexOne = {};
        Set<String> indexTwo = {};
        for (String condition in decisionNode.conditions.keys) {
          List<String> conditionList = condition.split('#');
          indexOne.add(conditionList[0]);
          indexTwo.add(conditionList[1]);
        }

        String valueOne = '';
        String valueTwo = '';
        if (AppState.instance.formTempMap
            .containsKey(decisionNode.sources[0])) {
          /// Checking for the first source
          if (indexOne.contains(
              AppState.instance.formTempMap[decisionNode.sources[0]])) {
            valueOne = AppState.instance.formTempMap[decisionNode.sources[0]];
          } else {
            valueOne = constants.defaultKey;
          }
        } else if (clickedSubmissionValuesMap
            .containsKey(decisionNode.sources[0])) {
          /// Checking for the first source
          if (indexOne
              .contains(clickedSubmissionValuesMap[decisionNode.sources[0]])) {
            valueOne = clickedSubmissionValuesMap[decisionNode.sources[0]];
          } else {
            valueOne = constants.defaultKey;
          }
        } else {
          valueOne = constants.defaultKey;
        }

        if (AppState.instance.formTempMap
            .containsKey(decisionNode.sources[1])) {
          /// Checking for the first source
          if (indexTwo.contains(
              AppState.instance.formTempMap[decisionNode.sources[1]])) {
            valueTwo = AppState.instance.formTempMap[decisionNode.sources[1]];
          } else {
            valueTwo = constants.defaultKey;
          }
        } else if (clickedSubmissionValuesMap
            .containsKey(decisionNode.sources[1])) {
          /// Checking for the first source
          if (indexTwo
              .contains(clickedSubmissionValuesMap[decisionNode.sources[1]])) {
            valueTwo = clickedSubmissionValuesMap[decisionNode.sources[1]];
          } else {
            valueTwo = constants.defaultKey;
          }
        } else {
          valueTwo = constants.defaultKey;
        }

        String finalCondition = '$valueOne#$valueTwo';

        if (decisionNode.conditions.containsKey(finalCondition)) {
          subform = decisionNode.conditions[finalCondition][constants.subform];
        }
      } else if (decisionNode.sources.length == 1) {
        for (String key in decisionNode.sources) {
          if (AppState.instance.formTempMap.containsKey(key)) {
            values += '${AppState.instance.formTempMap[key]}#';
          } else if (clickedSubmissionValuesMap.containsKey(key)) {
            values += '${clickedSubmissionValuesMap[key]}#';
          }
        }
        if (values.isNotEmpty) {
          // Removing the last #
          values = values.substring(0, values.length - 1);
          if (decisionNode.conditions.containsKey(values)) {
            subform = decisionNode.conditions[values][constants.subform];
          } else if (decisionNode.conditions
              .containsKey(constants.defaultKey)) {
            subform = decisionNode.conditions[constants.defaultKey]
                [constants.subform];
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(constants.genericErrorMsg),
            ));
          }
        } else {
          if (decisionNode.conditions.containsKey(constants.defaultKey)) {
            subform = decisionNode.conditions[constants.defaultKey]
                [constants.subform];
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(constants.genericErrorMsg),
            ));
          }
        }
      }
    } else {
      // No sources to check, directly look for default subform

      if (decisionNode.conditions.containsKey(constants.defaultKey)) {
        subform =
            decisionNode.conditions[constants.defaultKey][constants.subform];
      }
    }
    if (subform.isNotEmpty) {
      // Set current form based on subform key
      if (currentForm.formType == constants.landingPage) {
        AppState.instance.clearFormTempMap();
        currentForm = emptyFormData();
        NavigationUtil.instance.navigateToFormScreen(context, subform);
      } else {
        findCurrentForm(subform);
        if (currentForm.formType == constants.landingPage) {
          currentForm = emptyFormData();
          findCurrentForm(subform);
          Navigator.of(context).pop('');
        }
        notifyListeners();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.genericErrorMsg),
      ));
    }
  }

  /// Custom implementation of a backstack for the form screen
  onBackPressed(BuildContext context) {
    /// To clear the validation error map after user press back button.
    errorWidgetMap.clear();
    if (backstack.isEmpty || backstack.length == 1) {
      /// 1. Clear temp and submission map
      /// 2. Close form screen
      clearFormMaps();
      Navigator.pop(context);
    } else {
      /// 1. Get current form, let's call it form Y
      /// 2. Get previous form on the backstack, let's call it form X
      /// 3. Set _currentForm to form X
      /// 4. Remove the form Y from the backstack
      /// 5. Set state
      FrameworkForm cForm = backstack.elementAt(backstack.length - 1);
      FrameworkForm previousForm = backstack.elementAt(backstack.length - 2);
      currentForm = previousForm;
      backstack.remove(cForm);

      if (cForm.formType == constants.previewScreenPage) {
        Navigator.pop(context);
        notifyListeners();
      }
      switch (currentForm.formType) {
        case constants.landingPage:
          {
            Navigator.pop(context);
            notifyListeners();
            break;
          }
        default:
          notifyListeners();
      }
    }
  }

  clearFormMaps() {
    AppState.instance.formTempMap.clear();
    AppState.instance.formTempWidgetMap.clear();
    currentForm = emptyFormData();
    backstack.clear();
    entityInstances = [];
    clickedSubmissionValuesMap.clear();
    filteredSubmissions = [];
    submissionIdToSubmissionMap.clear();
    isFilterApplied = false;
    imageFields.clear();
    datePickerFields.clear();
    clickedSubmissionId = '';
    orderPartItems.clear();
    dropdownValues.clear();
    dropdownNotLoadedCompletely.clear();
    dropDownValuesLoaded.clear();
    tempClickedSubmissionsMap.clear();
  }

  dataListButtonPressed(String formKey) {
    /// Opening subform
    findCurrentForm(formKey);
    notifyListeners();
  }

  /// Column to render all the form fields
  getFormFields() {
    List<Widget> fields = <Widget>[];
    List<FocusNode> focusList = [];
    for (FrameworkFormField field in currentForm.fields) {
      focusList.add(FocusNode());
      AppState.instance
          .addToFormTempWidgetMap(field.key, field, currentForm.entityKey);
      fields.add(
          FormRendererUtil.instance.getFormFieldWidget(field, this, focusList));
    }
    if (fields.isEmpty) {
      fields.add(const SizedBox());
    }
    return fields;
  }

  horizontalSeparator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: constants.smallPadding,
      ),
      child: Container(
        /*width: MediaQuery.of(context).size.width,*/
        height: constants.horizontalSeparatorHeight,
        color: const Color(constants.previewSeparatorColor),
      ),
    );
  }

  AlignmentGeometry getAlignment(String alignment) {
    switch (alignment.toLowerCase()) {
      case 'right':
        return Alignment.centerRight;
      case 'center':
        return Alignment.center;
      case 'left':
      default:
        return Alignment.centerLeft;
    }
  }

  /// Show the preview sub-form based on the decision nodes, and also create
  /// the submission map
  getPreviewFormFieldsBasedOnDecisionNodes(BuildContext context) {
    List<Widget> containers = <Widget>[];

    List<Widget> widgets = [];
    for (FrameworkForm form in backstack) {
      widgets.addAll((traverseSubForms(form, context)));
    }

    if (widgets.isNotEmpty) {
      widgets.removeAt(widgets.length - 1);
    }

    containers.add(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    ));

    /// Traverse sub-forms
    /* while (traversalForm.formType.isEmpty ||
        traversalForm.formType != constants.previewFormType) {
     */ /* containers.add(Padding(
        padding: const EdgeInsets.fromLTRB(
          0.0,
          constants.mediumPadding,
          0.0,
          constants.mediumPadding,
        ),
        child: Material(
          elevation: constants.formComponentsElevation,
          borderRadius: constants.materialBorderRadius,
          child: Container(
            */ /**/ /*width: MediaQuery.of(context).size.width,*/ /**/ /*
            decoration: constants.dropdownContainerDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: traverseSubForms(traversalForm, context),
            ),
          ),
        ),
      ));*/ /*

    */ /*  /// Get next form
      for (FrameworkFormButton button in traversalForm.buttons) {
        if (button.type == 1) {
          /// Next button type
          if (button.decisionNode.sources.isEmpty) {
            /// No decision node present, just look for default subform
            traversalForm = findFormByKey(button.decisionNode
                .conditions[constants.defaultKey][constants.subform]);
          } else {
            /// Decision node present
            if (button.decisionNode.sources.isNotEmpty) {
              /// 1 or more sources exist for this decision node
              if (button.decisionNode.sources.length == 2) {
                Set<String> indexOne = {};
                Set<String> indexTwo = {};
                for (String condition in button.decisionNode.conditions.keys) {
                  List<String> conditionList = condition.split('#');
                  indexOne.add(conditionList[0]);
                  indexTwo.add(conditionList[1]);
                }

                String valueOne = '';
                String valueTwo = '';
                if (AppState.instance.formTempMap
                    .containsKey(button.decisionNode.sources[0])) {
                  /// Checking for the first source
                  if (indexOne.contains(AppState
                      .instance.formTempMap[button.decisionNode.sources[0]])) {
                    valueOne = AppState
                        .instance.formTempMap[button.decisionNode.sources[0]];
                  } else {
                    valueOne = constants.defaultKey;
                  }
                } else {
                  valueOne = constants.defaultKey;
                }

                if (AppState.instance.formTempMap
                    .containsKey(button.decisionNode.sources[1])) {
                  /// Checking for the first source
                  if (indexTwo.contains(AppState
                      .instance.formTempMap[button.decisionNode.sources[1]])) {
                    valueTwo = AppState
                        .instance.formTempMap[button.decisionNode.sources[1]];
                  } else {
                    valueTwo = constants.defaultKey;
                  }
                } else {
                  valueTwo = constants.defaultKey;
                }

                String finalCondition = '$valueOne#$valueTwo';

                if (button.decisionNode.conditions
                    .containsKey(finalCondition)) {
                  traversalForm = findFormByKey(button.decisionNode
                      .conditions[finalCondition][constants.subform]);
                }
              } else if (button.decisionNode.sources.length == 1) {
                String values = '';
                for (String key in button.decisionNode.sources) {
                  if (AppState.instance.formTempMap.containsKey(key)) {
                    values += '${AppState.instance.formTempMap[key]}#';
                  } else if (clickedSubmissionValuesMap.containsKey(key)) {
                    values += '${clickedSubmissionValuesMap[key]}#';
                  }
                }
                if (values.isNotEmpty) {
                  // Removing the last #
                  values = values.substring(0, values.length - 1);
                  if (button.decisionNode.conditions.containsKey(values)) {
                    traversalForm = findFormByKey(button
                        .decisionNode.conditions[values][constants.subform]);
                  } else if (button.decisionNode.conditions
                      .containsKey(constants.defaultKey)) {
                    traversalForm = findFormByKey(button.decisionNode
                        .conditions[constants.defaultKey][constants.subform]);
                  }
                }
              }
            } else {
              /// Sources do not exist for this decision node
              if (button.decisionNode.conditions
                  .containsKey(constants.defaultKey)) {
                traversalForm = findFormByKey(button.decisionNode
                    .conditions[constants.defaultKey][constants.subform]);
              }
            }

            String values = '';
            for (String key in button.decisionNode.sources) {
              values += '${AppState.instance.formTempMap[key]}#';
            }
            // Removing the last #
            values = values.substring(0, values.length - 1);
            if (button.decisionNode.conditions.containsKey(values)) {
              traversalForm = findFormByKey(
                  button.decisionNode.conditions[values][constants.subform]);
            } else if (button.decisionNode.conditions
                .containsKey(constants.defaultKey)) {
              traversalForm = findFormByKey(button.decisionNode
                  .conditions[constants.defaultKey][constants.subform]);
            }
          }
        }
      }*/ /*
    }*/

    return containers;
  }

  traverseSubForms(FrameworkForm form, BuildContext context) {
    List<Widget> widgets = <Widget>[];

    for (FrameworkFormField field in form.fields) {
      if (field.uiType == constants.row || field.uiType == constants.subform) {
        FrameworkForm subform = findFormByKey(field.subform);
        List<Widget> subformWidgets = traverseSubForms(subform, context);
        if (subformWidgets.isNotEmpty) {
          widgets.addAll(subformWidgets);
          widgets.add(horizontalSeparator(context));
        }
      } else if (field.uiType == constants.button) {
        //todo differentiat is this button for submission or next screen click or inbetween the screen
        /* String subformKey = '';
        FrameworkForm subform = const FrameworkForm(
            formKey: '',
            formName: '',
            entityKey: '',
            parentEntityKey: '',
            formType: '',
            fields: [],
            buttons: [],
            navBar: []);
        if (field.decisionNode.sources.isNotEmpty) {
          String values = '';

          if (field.decisionNode.sources.length == 2) {
            Set<String> indexOne = {};
            Set<String> indexTwo = {};
            for (String condition in field.decisionNode.conditions.keys) {
              List<String> conditionList = condition.split('#');
              indexOne.add(conditionList[0]);
              indexTwo.add(conditionList[1]);
            }

            String valueOne = '';
            String valueTwo = '';
            if (AppState.instance.formTempMap
                .containsKey(field.decisionNode.sources[0])) {
              /// Checking for the first source
              if (indexOne.contains(AppState
                  .instance.formTempMap[field.decisionNode.sources[0]])) {
                valueOne = AppState
                    .instance.formTempMap[field.decisionNode.sources[0]];
              } else {
                valueOne = constants.defaultKey;
              }
            } else {
              valueOne = constants.defaultKey;
            }

            if (AppState.instance.formTempMap
                .containsKey(field.decisionNode.sources[1])) {
              /// Checking for the first source
              if (indexTwo.contains(AppState
                  .instance.formTempMap[field.decisionNode.sources[1]])) {
                valueTwo = AppState
                    .instance.formTempMap[field.decisionNode.sources[1]];
              } else {
                valueTwo = constants.defaultKey;
              }
            } else {
              valueTwo = constants.defaultKey;
            }

            String finalCondition = '$valueOne#$valueTwo';

            if (field.decisionNode.conditions.containsKey(finalCondition)) {
              subformKey = field.decisionNode.conditions[finalCondition]
                  [constants.subform];
            }
          } else if (field.decisionNode.sources.length == 1) {
            for (String key in field.decisionNode.sources) {
              values += '${AppState.instance.formTempMap[key]}#';
            }
            if (values.isNotEmpty) {
              /// Removing the last #
              values = values.substring(0, values.length - 1);
              if (field.decisionNode.conditions.containsKey(values)) {
                subformKey =
                    field.decisionNode.conditions[values][constants.subform];
              } else if (field.decisionNode.conditions
                  .containsKey(constants.defaultKey)) {
                subformKey = field.decisionNode.conditions[constants.defaultKey]
                    [constants.subform];
              }
            } else {
              /// No sources to check, directly look for default subform
              if (field.decisionNode.conditions
                  .containsKey(constants.defaultKey)) {
                subformKey = field.decisionNode.conditions[constants.defaultKey]
                    [constants.subform];
              }
            }
          }
        } else {
          /// No sources to check, directly look for default subform
          if (field.decisionNode.conditions.containsKey(constants.defaultKey)) {
            subformKey = field.decisionNode.conditions[constants.defaultKey]
                [constants.subform];
          }
        }
        if (subformKey.isNotEmpty) {
          subform = findFormByKey(subformKey);
        }
        List<Widget> subformWidgets = traverseSubForms(subform, context);
        if (subformWidgets.isNotEmpty) {
          widgets.addAll(subformWidgets);
          widgets.add(horizontalSeparator(context));
        }*/
        break;
      } else if (field.uiType == constants.edittext ||
          field.uiType == constants.numericEdittext ||
          field.uiType == constants.address ||
          field.uiType == constants.geotag ||
          field.uiType == constants.scanner) {
        String value = '';
        if (AppState.instance.formTempMap.containsKey(field.key)) {
          value = AppState.instance.formTempMap[field.key];
        } else if (clickedSubmissionValuesMap.containsKey(field.key)) {
          value = clickedSubmissionValuesMap[field.key];
        }
        if (value.isNotEmpty) {
          widgets.add(FormPreviewFieldWidget(
            key: Key('${constants.headerKeyPrefix}${field.key}'),
            fieldKey: field.key,
            field: field,
            viewModel: this,
          ));
          widgets.add(horizontalSeparator(context));
        }
      } else if (field.uiType == constants.date) {
        if (AppState.instance.formTempMap.containsKey(field.key) ||
            clickedSubmissionValuesMap.containsKey(field.key)) {
          widgets.add(FormPreviewFieldWidget(
            key: Key('${constants.headerKeyPrefix}${field.key}'),
            fieldKey: field.key,
            field: field,
            viewModel: this,
          ));
          widgets.add(horizontalSeparator(context));
        }
      } else if (field.uiType == constants.image ||
          field.uiType == constants.filePicker) {
        List<dynamic> images = [];
        if (AppState.instance.formTempMap.containsKey(field.key)) {
          images.addAll(AppState.instance.formTempMap[field.key]);
        } else if (clickedSubmissionValuesMap.containsKey(field.key)) {
          String hashSeparatedString = clickedSubmissionValuesMap[field.key];
          List<String> imageNames = hashSeparatedString.split('#');
          for (String i in imageNames) {
            images.add(FormImageFieldWidgetMedia(
                false, i, null, '${constants.s3BucketBaseUrl}$i'));
          }
          images = clickedSubmissionValuesMap[field.key];
        }
        if (images.isNotEmpty) {
          widgets.add(FormPreviewFieldWidget(
            key: Key('${constants.headerKeyPrefix}${field.key}'),
            fieldKey: field.key,
            field: field,
            viewModel: this,
          ));
          widgets.add(horizontalSeparator(context));
        }
      } else if (field.uiType == constants.dropdown ||
          field.uiType == constants.singleSelectCheckbox ||
          field.uiType == constants.radio) {
        String value = '';
        if (AppState.instance.formTempMap.containsKey(field.key)) {
          value = AppState.instance.formTempMap[field.key];
        } else if (clickedSubmissionValuesMap.containsKey(field.key)) {
          value = clickedSubmissionValuesMap[field.key];
        }
        if (value.isNotEmpty) {
          widgets.add(FormPreviewFieldWidget(
            key: Key('${constants.headerKeyPrefix}${field.key}'),
            fieldKey: field.key,
            field: field,
            viewModel: this,
          ));
          widgets.add(horizontalSeparator(context));

          /// Dropdown or checkbox could have a subform linked to it, based
          /// on value selection
          FrameworkForm subform = emptyFormData();
          if (field.values.isNotEmpty) {
            for (FrameworkFormFieldValue v in field.values) {
              if (v.value == value) {
                if (v.decisionNode.conditions.isNotEmpty) {
                  subform = findFormByKey(v.decisionNode
                      .conditions[constants.defaultKey][constants.subform]);
                  break;
                }
              }
            }
          } else if (field.valuesApi.values.isNotEmpty) {
            for (FrameworkFormFieldValue v in field.valuesApi.values) {
              if (v.value == value) {
                if (v.decisionNode.conditions.isNotEmpty) {
                  subform = findFormByKey(v.decisionNode
                      .conditions[constants.defaultKey][constants.subform]);
                  break;
                }
              }
            }
          }
          if (subform.formKey.isNotEmpty) {
            /// Valid subform exists for this selection of the checkbox
            List<Widget> subformWidgets = traverseSubForms(subform, context);
            if (subformWidgets.isNotEmpty) {
              widgets.addAll(subformWidgets);
              widgets.add(horizontalSeparator(context));
            }
          }
        }
      }
    }

    return widgets;
  }

  /// The form could contain fields like rows, that have sub-forms associated with them
  /// that contain more fields that are part of the add item widget.
  /// This function returns a flattened list of all the widgets that the user
  /// can enter data for from the arraylist of forms.
  getAllFieldsForItem(FrameworkForm form) {
    List<FrameworkFormField> fields = [];
    for (FrameworkFormField field in form.fields) {
      if (field.uiType == constants.edittext ||
          field.uiType == constants.numericEdittext ||
          field.uiType == constants.address ||
          field.uiType == constants.date ||
          field.uiType == constants.singleSelectCheckbox ||
          field.uiType == constants.image ||
          field.uiType == constants.scanner) {
        fields.add(field);
      } else if (field.uiType == constants.row) {
        /// As this field is a row, we are fetching the subform and recursively
        /// calling this function to return the fields
        FrameworkForm subform = findFormByKey(field.subform);
        fields.addAll(getAllFieldsForItem(subform));
      } else if (field.uiType == constants.dropdown) {
        fields.add(field);
        if (field.values.isNotEmpty) {
          for (FrameworkFormFieldValue v in field.values) {
            if (v.decisionNode.conditions.isNotEmpty) {
              FrameworkForm subform = findFormByKey(v.decisionNode
                  .conditions[constants.defaultKey][constants.subform]);
              fields.addAll(_getAllFieldsForItem(subform));
            }
          }
        } else if (field.valuesApi.values.isNotEmpty) {
          for (FrameworkFormFieldValue v in field.valuesApi.values) {
            if (v.decisionNode.conditions.isNotEmpty) {
              FrameworkForm subform = findFormByKey(v.decisionNode
                  .conditions[constants.defaultKey][constants.subform]);
              fields.addAll(_getAllFieldsForItem(subform));
            }
          }
        }
      }
    }
    return fields;
  }

  /// 1. This method is called once the user clicks on the submit button.
  /// 2. From the formTempMap we pick the user entered data and add it to
  /// this submission model.
  /// 3. This submission model is then used in the submission API to submit
  /// data to the server.
  Future<bool> createFormSubmission(BuildContext context) async {
    bool submissionModelCreated = false;

    /// Check if this project has been submitted before
    if (clickedSubmissionValuesMap.isNotEmpty) {
      /// This project has been submitted before
      /// 1. Add the changed values to the existing entities
      if (userSubmissions != null &&
          userSubmissions!.submissionList.isNotEmpty) {
        for (ServerSubmission submission in userSubmissions!.submissionList) {
          if (submission.submissionId == clickedSubmissionId) {
            /// Found the existing submission for this project
            /// Clear the submission object, and initialize it with the previous submission
            entityInstances.clear();
            for (String entityInstanceString in submission.entities) {
              Map<String, dynamic> entityJson =
                  jsonDecode(entityInstanceString);
              EntityInstance entity = EntityInstance.fromJson(entityJson);
              entityInstances.add(entity);
            }
            break;
          }
        }

        /// Iterate through the values of the entities and add any values
        /// changed in the current submission session
        List<EntityInstance> tempEntities = <EntityInstance>[];
        for (EntityInstance entityInstance in entityInstances) {
          /// Creating a tempEntity to add the previous submission
          /// fields and current fields to it
          EntityInstance tempEntity = EntityInstance(
              id: entityInstance.id,
              key: entityInstance.key,
              parentId: entityInstance.parentId,
              childIds: entityInstance.childIds,
              submissionField: []);
          List<SubmissionField> tempSubmissionFields = <SubmissionField>[];
          for (SubmissionField field in entityInstance.submissionField) {
            if (imageFields.containsKey(field.key) ||
                filePickerFields.containsKey(field.key)) {
              String dialogText = imageFields.containsKey(field.key)
                  ? "Uploading images"
                  : "Uploading files";

              /// Image field
              if (AppState.instance.formTempMap.containsKey(field.key)) {
                /// User has altered the images
                List<dynamic> value = [];
                value.addAll(AppState.instance.formTempMap[field.key]);
                if (value.isNotEmpty) {
                  int imageUploadCount = 0;
                  int count = value.length;
                  String finalValue = '';
                  List<String> imageUrlList = [];
                  for (var model in value) {
                    FormImageFieldWidgetMedia image;
                    if (model is FormImageFieldWidgetMedia) {
                      image = model;
                    } else {
                      continue;
                    }
                    imageUploadCount = imageUploadCount + 1;
                    if (buildContext != null) {
                      DialogBuilder(buildContext).showLoadingIndicator(
                          '$dialogText $imageUploadCount/$count');
                    }
                    if (image.isLocal) {
                      File media = File(image.path!);
                      String imageUrl =
                          await ImageUploadProvider().uploadMediaToS3(media);
                      if (imageUrl.isNotEmpty) {
                        imageUrlList.add(imageUrl);
                        finalValue = '$finalValue${imageUrl}#';
                      } else {
                        DialogBuilder(context).hideOpenDialog();
                        return false;
                      }
                    } else {
                      imageUrlList.add(image.url!);
                    }
                  }

                  AppState.instance.formTempMap[field.key] =
                      imageUrlList.toString();

                  /// Removing last # from the string value to be submitted
                  finalValue = finalValue.substring(0, finalValue.length - 1);
                  SubmissionField tempField = field;
                  tempField.value = finalValue;
                  tempSubmissionFields.add(tempField);
                }
              } else {
                /// User has not altered the images
                tempSubmissionFields.add(field);
              }
            } else if (datePickerFields.containsKey(field.key)) {
              if (AppState.instance.formTempMap.containsKey(field.key)) {
                SubmissionField tempField = field;
                DateTime dValue = AppState.instance.formTempMap[field.key];
                tempField.value = dValue.millisecondsSinceEpoch.toString();
                tempSubmissionFields.add(tempField);
              }
            } else {
              /// Form field (Except image and date picker)
              if (AppState.instance.formTempMap.containsKey(field.key)) {
                SubmissionField tempField = field;
                tempField.value = AppState.instance.formTempMap[field.key];
                tempSubmissionFields.add(tempField);
              } else {
                tempSubmissionFields.add(field);
              }
            }
          }
          tempEntity.submissionField.addAll(tempSubmissionFields);
          tempEntities.add(tempEntity);
        }
        entityInstances.clear();
        entityInstances.addAll(tempEntities);

        submissionModelCreated = true;
      }
    } else {
      /// This is a fresh submission
      if (formsList.initialFormKey.isNotEmpty && formsList.forms.isNotEmpty) {
        /// Using this initialFormKey and the list of forms, we will iterate
        /// through the forms based on user selection and create the entity
        /// instances for the submission
        FrameworkForm form = findFormByKey(formsList.initialFormKey);
        if (form.formKey.isNotEmpty) {
          entityInstances = [];
          await _addValuesToEntityInstances(form);
          submissionModelCreated = true;
        } else {
          /// No valid form found
          Util.instance.logMessage(
              'Form View Model',
              'No valid form found - form'
                  ' submission model creation failed');
        }
      } else {
        /// No valid form or initial form ID exists
        Util.instance.logMessage(
            'Form View Model',
            'No valid form or initial '
                'form ID exists - form submission model creation failed');
      }
    }

    /// Add any hidden field values to the submission
    /*if (button.preSubmissionFields.isNotEmpty) {
      _preSubmissionFieldsAddition(button);
    }*/
    return submissionModelCreated;
  }

  /// This method is called if the submission button contains any pre
  /// submission fields.
  /// Pre submission fields are hidden fields that are not user editable, but
  /// need to be submitted along with the project
  _preSubmissionFieldsAddition(FrameworkFormButton button) {
    /// Iterating through all the pre submission fields
    for (PreSubmissionField field in button.preSubmissionFields) {
      if (field.key.isNotEmpty &&
          field.entity.isNotEmpty &&
          field.value.isNotEmpty) {
        for (EntityInstance instance in entityInstances) {
          if (instance.key == field.entity) {
            entityInstances
                .elementAt(entityInstances.indexOf(instance))
                .submissionField
                .add(SubmissionField(key: field.key, value: field.value));
            break;
          }
        }
      }
    }
  }

  /// This method adds form media to the hive box for media sync
  _addFormMediaToHiveBox(List<FormMediaModel> formMediaList) async {
    Box formMediaBox = await Hive.openBox(constants.formMediaBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));
    List<dynamic> hiveMediaEntries = [];
    hiveMediaEntries
        .addAll(formMediaBox.get(AppState.instance.userId.toLowerCase()) ?? []);
    if (hiveMediaEntries.isNotEmpty) {
      /// Existing media already exists
      hiveMediaEntries.addAll(formMediaList);
      formMediaBox.put(
          AppState.instance.userId.toLowerCase(), hiveMediaEntries);
    } else {
      /// No media exists in hive box
      formMediaBox.put(AppState.instance.userId.toLowerCase(), formMediaList);
    }
  }

  _addValuesToEntityInstances(FrameworkForm form) async {
    /// 1. Check if entity instance exists for the given entity key for the form.
    /// 2. If it does not, create new entity instance.
    /// 3. If it does, add the fields data to the entity instance (from formTempMap).
    /// 4. Once all fields from this form are done, iterate through the buttons and
    /// call this function recursively with the new  form if needed (we can stop
    /// when we reach either the preview form or the submission button
    String entityKey = form.entityKey;
    if (entityKey.isEmpty) {
      /// Error - Entity key is empty
      Util.instance.logMessage(
          'Form View Model',
          'No valid entity key found '
              '- Entity key is empty');
    }

    /// Iterating through all the form fields and adding values to the entity instances
    List<SubmissionField> submissionFields = <SubmissionField>[];
    for (FrameworkFormField field in form.fields) {
      String value = '';
      if (field.uiType == constants.edittext ||
          field.uiType == constants.numericEdittext ||
          field.uiType == constants.address ||
          field.uiType == constants.geotag ||
          field.uiType == constants.scanner) {
        /// These values cannot lead to other sub-forms
        if (AppState.instance.formTempMap[field.key] != null &&
            AppState.instance.formTempMap[field.key].toString().isNotEmpty) {
          value = AppState.instance.formTempMap[field.key].toString();
        }
      } else if (field.uiType == constants.dropdown ||
          field.uiType == constants.singleSelectCheckbox ||
          field.uiType == constants.radio) {
        /// These values can lead to other sub-forms
        if (AppState.instance.formTempMap[field.key] != null &&
            AppState.instance.formTempMap[field.key].toString().isNotEmpty) {
          value = AppState.instance.formTempMap[field.key].toString();

          /// Checking for any sub-forms linked to the selected value and
          /// recursively calling function if needed
          FrameworkForm subForm = emptyFormData();
          if (value.isNotEmpty) {
            if (field.values.isNotEmpty) {
              for (FrameworkFormFieldValue v in field.values) {
                if (v.value == value) {
                  if (v.decisionNode.conditions.isNotEmpty) {
                    subForm = findFormByKey(v.decisionNode
                        .conditions[constants.defaultKey][constants.subform]);
                    break;
                  }
                }
              }
            } else if (field.valuesApi.values.isNotEmpty) {
              for (FrameworkFormFieldValue v in field.valuesApi.values) {
                if (v.value == value) {
                  if (v.decisionNode.conditions.isNotEmpty) {
                    subForm = findFormByKey(v.decisionNode
                        .conditions[constants.defaultKey][constants.subform]);
                    break;
                  }
                }
              }
            }
            if (subForm.formKey.isNotEmpty) {
              /// Valid subform exists for this selection of the field
              await _addValuesToEntityInstances(subForm);
            }
          }
        }
      } else if (field.uiType == constants.date) {
        /// Date widget - The value is sent as a string containing milli seconds since epoch
        if (AppState.instance.formTempMap[field.key] != null) {
          DateTime v = AppState.instance.formTempMap[field.key];
          value = v.millisecondsSinceEpoch.toString();
        }
      } else if (field.uiType == constants.dateRange) {
        /// Date Range widget - The value is sent as a string containing milli
        /// seconds since epoch for start and end time
        String s = AppState.instance.formTempMap[field.key];
        List<String> dateRange = s.split('#');
        DateTime start = DateTime.parse(dateRange[0]);
        DateTime end = DateTime.parse(dateRange[1]);
        value =
            '${start.millisecondsSinceEpoch.toString()}#${end.millisecondsSinceEpoch.toString()}';
      } else if (field.uiType == constants.image ||
          field.uiType == constants.filePicker) {
        /// Image widget
        List<dynamic> images = AppState.instance.formTempMap[field.key];
        if (images != null && images.isNotEmpty) {
          List<String> imageUrlList = [];

          /// 1. Images have been clicked and their names have to be submitted
          /// with the form data
          /// 2. Create Hive entries for these images, so that the media sync
          /// service can upload these images to AWS S3
          int uploadedCount = 0;
          String dialogText = field.uiType == constants.image
              ? "Uploading images"
              : "Uploading files";

          for (FormImageFieldWidgetMedia image in images) {
            int totalImage = images.length;
            uploadedCount = uploadedCount + 1;
            DialogBuilder(buildContext)
                .showLoadingIndicator('$dialogText $uploadedCount/$totalImage');
            if (image.isLocal) {
              File media = File(image.path!);
              String imageUrl =
                  await ImageUploadProvider().uploadMediaToS3(media);
              if (imageUrl.isNotEmpty) {
                imageUrlList.add(imageUrl);
                DialogBuilder(buildContext).hideOpenDialog();
              } else {
                DialogBuilder(buildContext).hideOpenDialog();
                return false;
              }
            }
          }

          if (imageUrlList.isNotEmpty) {
            AppState.instance.formTempMap[field.key] = imageUrlList;
          }

          /// Removing last # from the string value to be submitted
          if (value.isNotEmpty) {
            value = value.substring(0, value.length - 1);
          }
        }
      } else if (field.uiType == constants.subform) {
        /// Subform widget
        /// Finding the subform mentioned in the subform key
        FrameworkForm subForm = findFormByKey(field.subform);
        if (subForm.formKey.isNotEmpty) {
          await _addValuesToEntityInstances(subForm);
        }
      } else if (field.uiType == constants.button) {
        /// Form button widget
        /// Finding the subform that this button leads to
        if (!field.valuesApi.isPreview) {
          FrameworkForm subForm =
              _searchNextFormUsingDecisionNode(field.decisionNode);
          if (subForm.formKey.isNotEmpty) {
            await _addValuesToEntityInstances(subForm);
          }
        }
      } else if (field.uiType == constants.dataList) {
        /// Data list widget
        /// Finding subform that is rendered when the user clicks on the data list item
        FrameworkForm subForm = findFormByKey(field.dataListClickSubform);
        if (subForm.formKey.isNotEmpty) {
          await _addValuesToEntityInstances(subForm);
        }
      } else if (field.uiType == constants.tabs) {
        /// Tabs widget
        /// Iterating through the tab values and their sub-forms
        for (FrameworkFormFieldValue v in field.values) {
          FrameworkForm subForm =
              _searchNextFormUsingDecisionNode(v.decisionNode);
          if (subForm.formKey.isNotEmpty) {
            await _addValuesToEntityInstances(subForm);
          }
        }
      }
      if (value.isNotEmpty) {
        submissionFields.add(SubmissionField(key: field.key, value: value));
      }
    }

    bool entityExists = _checkIfEntityExists(entityKey);

    /// Adding submissionField list to the entityInstance
    if (!entityExists) {
      /// Entity does not exist, create a new instance of the given entity,
      /// and then add the fields and their values to this entity instance
      String entityId = const Uuid().v1();
      String? parentEntityId;

      /// If parent entity key exists, adding the parent entity id to this instance
      if (form.parentEntityKey != '') {
        for (EntityInstance entityInstance in entityInstances) {
          if (entityInstance.key == form.parentEntityKey) {
            parentEntityId = entityInstance.id;

            /// To this parent entity instance, adding child id
            entityInstances.remove(entityInstance);
            entityInstance.childIds.add(entityId);
            entityInstances.add(entityInstance);
            break;
          }
        }
      }
      List<String> childEntityIds = [];
      EntityInstance entityInstance = EntityInstance(
          id: entityId,
          key: entityKey,
          parentId: parentEntityId,
          childIds: childEntityIds,
          submissionField: submissionFields);
      entityInstances.add(entityInstance);
    } else {
      /// Entity exists, add the submissionFields to the existing entity instance
      for (EntityInstance entityInstance in entityInstances) {
        if (entityInstance.key == entityKey) {
          /// Found the entity instance  for which the fields need to be added
          /// 1. Removing the instance
          /// 2. Adding submissionFields to the temp variable
          /// 3. Adding temp instance to the formSubmission object
          entityInstances.remove(entityInstance);
          entityInstance.submissionField.addAll(submissionFields);
          entityInstances.add(entityInstance);
        }
      }
    }

    /// Iterating through all the form buttons and calling function recursively
    /// if required
    for (FrameworkFormButton button in form.buttons) {
      switch (button.type) {
        case 1:

          /// Next button
          FrameworkForm subForm =
              _searchNextFormUsingDecisionNode(button.decisionNode);
          if (subForm.formKey.isNotEmpty) {
            await _addValuesToEntityInstances(subForm);
          }
          break;
      }
    }
  }

  /// This method returns subform for the field or button based on the decision node
  _searchNextFormUsingDecisionNode(DecisionNode decisionNode) {
    String subform = '';
    FrameworkForm subForm = emptyFormData();
    if (decisionNode.sources.isNotEmpty) {
      String values = '';

      if (decisionNode.sources.length == 2) {
        Set<String> indexOne = {};
        Set<String> indexTwo = {};
        for (String condition in decisionNode.conditions.keys) {
          List<String> conditionList = condition.split('#');
          indexOne.add(conditionList[0]);
          indexTwo.add(conditionList[1]);
        }

        String valueOne = '';
        String valueTwo = '';
        if (AppState.instance.formTempMap
            .containsKey(decisionNode.sources[0])) {
          /// Checking for the first source
          if (indexOne.contains(
              AppState.instance.formTempMap[decisionNode.sources[0]])) {
            valueOne = AppState.instance.formTempMap[decisionNode.sources[0]];
          } else {
            valueOne = constants.defaultKey;
          }
        } else {
          valueOne = constants.defaultKey;
        }

        if (AppState.instance.formTempMap
            .containsKey(decisionNode.sources[1])) {
          /// Checking for the first source
          if (indexTwo.contains(
              AppState.instance.formTempMap[decisionNode.sources[1]])) {
            valueTwo = AppState.instance.formTempMap[decisionNode.sources[1]];
          } else {
            valueTwo = constants.defaultKey;
          }
        } else {
          valueTwo = constants.defaultKey;
        }

        String finalCondition = '$valueOne#$valueTwo';

        if (decisionNode.conditions.containsKey(finalCondition)) {
          subform = decisionNode.conditions[finalCondition][constants.subform];
        }
      } else if (decisionNode.sources.length == 1) {
        for (String key in decisionNode.sources) {
          values += '${AppState.instance.formTempMap[key]}#';
        }
        if (values.isNotEmpty) {
          /// Removing the last #
          values = values.substring(0, values.length - 1);
          if (decisionNode.conditions.containsKey(values)) {
            subform = decisionNode.conditions[values][constants.subform];
          } else if (decisionNode.conditions
              .containsKey(constants.defaultKey)) {
            subform = decisionNode.conditions[constants.defaultKey]
                [constants.subform];
          }
        } else {
          /// No sources to check, directly look for default subform
          if (decisionNode.conditions.containsKey(constants.defaultKey)) {
            subform = decisionNode.conditions[constants.defaultKey]
                [constants.subform];
          }
        }
      }
    } else {
      /// No sources to check, directly look for default subform
      if (decisionNode.conditions.containsKey(constants.defaultKey)) {
        subform =
            decisionNode.conditions[constants.defaultKey][constants.subform];
      }
    }
    if (subform.isNotEmpty) {
      subForm = findFormByKey(subform);
    }
    return subForm;
  }

  /// This method returns true if a particular entity instance exists
  /// in the submission model
  _checkIfEntityExists(String key) {
    bool entityExists = false;
    for (EntityInstance entity in entityInstances) {
      if (entity.key == key) {
        entityExists = true;
        break;
      }
    }
    return entityExists;
  }

  /// The sub-form for add item widget could contain fields like rows, that have
  /// sub-forms associated with them that contain more fields that are part
  /// of the widget.
  /// This function returns a flattened list of all the widgets that the user
  /// can enter data for from the arraylist of forms.
  _getAllFieldsForItem(FrameworkForm form) {
    List<FrameworkFormField> fields = [];
    for (FrameworkFormField field in form.fields) {
      if (field.uiType == constants.edittext ||
          field.uiType == constants.numericEdittext ||
          field.uiType == constants.address ||
          field.uiType == constants.date ||
          field.uiType == constants.singleSelectCheckbox ||
          field.uiType == constants.image ||
          field.uiType == constants.scanner) {
        fields.add(field);
      } else if (field.uiType == constants.row) {
        /// As this field is a row, we are fetching the subform and recursively
        /// calling this function to return the fields
        FrameworkForm subform = findFormByKey(field.subform);
        fields.addAll(_getAllFieldsForItem(subform));
      } else if (field.uiType == constants.dropdown) {
        fields.add(field);
        if (field.values.isNotEmpty) {
          for (FrameworkFormFieldValue v in field.values) {
            if (v.decisionNode.conditions.isNotEmpty) {
              FrameworkForm subform = findFormByKey(v.decisionNode
                  .conditions[constants.defaultKey][constants.subform]);
              fields.addAll(_getAllFieldsForItem(subform));
            }
          }
        } else if (field.valuesApi.values.isNotEmpty) {
          for (FrameworkFormFieldValue v in field.valuesApi.values) {
            if (v.decisionNode.conditions.isNotEmpty) {
              FrameworkForm subform = findFormByKey(v.decisionNode
                  .conditions[constants.defaultKey][constants.subform]);
              fields.addAll(_getAllFieldsForItem(subform));
            }
          }
        }
      }
    }
    return fields;
  }

  /// This method is called to create a string list containing the values
  /// for a form dropdown
  createStringListForDropdown(FrameworkFormField field, String fieldKey,
      BuildContext context, bool notify) async {
    dropDownValuesLoaded[fieldKey] = false;
    List<String> values = <String>[];
    if (field.values.isNotEmpty) {
      /// Values are mentioned in the form
      for (FrameworkFormFieldValue value in field.values) {
        if (value.value.isNotEmpty) {
          values.add(value.value);
        }
      }
    } else if (field.valuesApi.url.isNotEmpty &&
        field.valuesApi.type.isNotEmpty &&
        field.valuesApi.responseParameter != null &&
        field.valuesApi.responseParameter.label.isNotEmpty &&
        field.valuesApi.type == constants.getAPI) {
      /// Values are to be fetched from GET API dynamically
      /// The response is required to be in a particular format
      if (await networkUtils.hasActiveInternet()) {
        values.addAll(await fetchDropdownValuesFromGetApi(field.valuesApi.url,
            field.valuesApi.responseParameter.label, context));

        if (values.isNotEmpty) {
          /// Caching dropdown values returned from API for offline use
          var dropdownValuesBox;
          dropdownValuesBox = await Hive.openBox(constants.dropdownValuesBox,
              encryptionCipher: HiveAesCipher(base64Decode(
                  AppState.instance.hiveEncryptionKey.toString())));
          List<dynamic>? cachedDropdownValues;
          cachedDropdownValues = dropdownValuesBox.get(fieldKey);
          if (cachedDropdownValues != null && cachedDropdownValues.isNotEmpty) {
            dropdownValuesBox.put(fieldKey, []);
          }
          dropdownValuesBox.put(fieldKey, values);
          Util.instance.logMessage(
              'Forms View Model',
              'Cached dropdown values'
                  ' added for $fieldKey');
        }
      } else {
        /// Checking if the values are cached for this dropdown
        var dropdownValuesBox;
        dropdownValuesBox = await Hive.openBox(constants.dropdownValuesBox,
            encryptionCipher: HiveAesCipher(
                base64Decode(AppState.instance.hiveEncryptionKey.toString())));
        List<dynamic>? cachedDropdownValues;
        cachedDropdownValues = dropdownValuesBox.get(fieldKey);
        if (cachedDropdownValues != null && cachedDropdownValues.isNotEmpty) {
          Util.instance.logMessage(
              'Forms View Model',
              'Cached dropdown values'
                  ' exist for $fieldKey');
          for (String value in cachedDropdownValues) {
            values.add(value);
          }
        } else {
          Util.instance.logMessage(
              'Forms View Model',
              'Error while fetching'
                  ' dropdown -- No internet connection');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${constants.noNetworkAvailability}. '
                'Cannot fetch value for ${field.label}'),
          ));
        }
      }
    } else if (field.valuesApi.url.isNotEmpty &&
        field.valuesApi.type.isNotEmpty &&
        field.valuesApi.responseParameter != null &&
        field.valuesApi.responseParameter.label.isNotEmpty &&
        field.valuesApi.type == constants.postAPI) {
      /// Values are to be fetched from POST API dynamically
      /// The response is required to be in a particular format
      /// Check if any parameters need to be added to the request
      List<RequestKey> requestKeys = field.valuesApi.requestKeys;

      if (requestKeys.isNotEmpty) {
        bool allKeysPresent = true;
        for (RequestKey rk in requestKeys) {
          if (!AppState.instance.formTempMap.containsKey(rk.formKey) ||
              AppState.instance.formTempMap[rk.formKey].isEmpty) {
            allKeysPresent = false;
            break;
          }
        }

        if (allKeysPresent) {
          if (await networkUtils.hasActiveInternet()) {
            /// Create request params
            Map<String, String> params = {};
            for (RequestKey rk in requestKeys) {
              params[rk.key] = AppState.instance.formTempMap[rk.formKey];
            }

            /// Call post API
            values.addAll(await fetchDropdownValuesFromPostApi(
                field.valuesApi.url,
                field.valuesApi.responseParameter.label,
                params,
                fieldKey,
                context));
          }
        }
      } else {
        if (await networkUtils.hasActiveInternet()) {
          /// Call post API
          values.addAll(await fetchDropdownValuesFromPostApi(
              field.valuesApi.url,
              field.valuesApi.responseParameter.label,
              {},
              fieldKey,
              context));
        }
      }
    }

    /// Adding the values for the dropdown to the view model map
    dropdownValues[fieldKey] = [];
    dropdownValues[fieldKey]!.addAll(values);
    if (dropdownValues[fieldKey]!.isNotEmpty) {
      dropDownValuesLoaded[fieldKey] = true;
    }
    if (notify) {
      notifyListeners();
    }
  }

  /// This method is called to fetch values of dropdowns dynamically
  /// through a GET API
  fetchDropdownValuesFromGetApi(
      String url, String responseKey, BuildContext context) async {
    List<String> values = [];
    values.addAll(await repo.fetchDropdownValues(url, responseKey, context));
    return values;
  }

  /// This method is called to fetch values of dropdowns dynamically
  /// through a POST API
  fetchDropdownValuesFromPostApi(String url, String responseKey,
      Map<String, String> params, String fieldKey, BuildContext context) async {
    List<String> values = [];
    values.addAll(await repo.fetchDropdownValueUsingPostAPI(
        this, url, responseKey, params, fieldKey, context));
    return values;
  }

  scrollToFirstValidationErrorWidget(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrolledToFirstErrorWidget) {
        Scrollable.ensureVisible(context);
        scrolledToFirstErrorWidget = true;
      }
    });
  }

  getAddressFromLocation(
      FrameworkFormField field, BuildContext buildContext) async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await AppState.instance.location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await AppState.instance.location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(buildContext).showSnackBar(const SnackBar(
          content: Text(constants.initializeLocationServiceMessage),
        ));
        return;
      }
    }

    /// Checking if the user has granted the location permission
    permissionGranted = await AppState.instance.location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await AppState.instance.location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        ScaffoldMessenger.of(buildContext).showSnackBar(const SnackBar(
          content: Text(constants.grantLocationPermission),
        ));
        return;
      }
    }

    if (AppState.instance.currentUserLocation != null &&
        AppState.instance.currentUserLocation!.latitude != null &&
        AppState.instance.currentUserLocation!.longitude != null) {
      /// Pick current user location and search for address
      await placemarkFromCoordinates(
              AppState.instance.currentUserLocation!.latitude!,
              AppState.instance.currentUserLocation!.longitude!)
          .then((List<Placemark> placemarks) {
        Placemark place = placemarks[0];
        /*String? name = place.name;*/
        String? street = place.street;
        String? country = place.country;
        String? postCode = place.postalCode;
        String? city = place.locality;
        String? locality = place.subLocality;
        String finalAddress = '';
        Set<String> addressSet = {};
        /*if(name != null && name.isNotEmpty) {
          addressSet.add(name);
        }*/
        if (street != null && street.isNotEmpty) {
          addressSet.add(street);
        }
        if (locality != null && locality.isNotEmpty) {
          addressSet.add(locality);
        }
        if (city != null && city.isNotEmpty) {
          addressSet.add(city);
        }
        if (country != null && country.isNotEmpty) {
          addressSet.add(country);
        }
        if (postCode != null && postCode.isNotEmpty) {
          addressSet.add(postCode);
        }
        for (String entry in addressSet) {
          finalAddress = '$finalAddress$entry, ';
        }
        if (finalAddress.isNotEmpty) {
          finalAddress = finalAddress.substring(0, finalAddress.length - 2);
        }

        /// Check for maximum length allowed for field
        if (field.max != null && finalAddress.length > field.max!) {
          /*if(name != null && name.isNotEmpty) {
            int l = name.length;
            l = l+2;
            finalAddress = finalAddress.substring(l, finalAddress.length);
          }*/
          if (street != null && street.isNotEmpty) {
            int l = street.length;
            l = l + 2;
            finalAddress = finalAddress.substring(l, finalAddress.length);
          }
          /*if(field.max != null && finalAddress.length > field.max!) {
            if(street != null && street.isNotEmpty) {
              int l = street.length;
              l = l+2;
              finalAddress = finalAddress.substring(l, finalAddress.length);
            }
          }*/
          if (field.max != null && finalAddress.length > field.max!) {
            if (locality != null && locality.isNotEmpty) {
              int l = locality.length;
              l = l + 2;
              finalAddress = finalAddress.substring(l, finalAddress.length);
            }
          }
          if (field.max != null && finalAddress.length > field.max!) {
            if (city != null && city.isNotEmpty) {
              int l = city.length;
              l = l + 2;
              finalAddress = finalAddress.substring(l, finalAddress.length);
            }
          }
          if (field.max != null && finalAddress.length > field.max!) {
            finalAddress = finalAddress.substring(0, field.max);
          }
        }
        AppState.instance.formTempMap[field.key] = finalAddress;
        notifyListeners();
      }).catchError((e) {
        debugPrint(e.toString());
        ScaffoldMessenger.of(buildContext).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
      });
    } else {
      AppState.instance.startTrackingUserLocation();
      ScaffoldMessenger.of(buildContext).showSnackBar(const SnackBar(
        content: Text(constants.initializeLocationMessage),
      ));
    }
  }

  Future<void> scanBarcode(
      FrameworkFormField field, BuildContext buildContext) async {
    String barcodeScanRes =
        await Navigator.of(buildContext).push(MaterialPageRoute(
      builder: (context) => ScanningView(field.label),
    ));
    if (barcodeScanRes != null && barcodeScanRes.isNotEmpty) {
      AppState.instance.formTempMap[field.key] = barcodeScanRes;
    }
    notifyListeners();
  }

  initializeTempClickedSubmissionValuesMap() {
    tempClickedSubmissionsMap.clear();
    tempClickedSubmissionsMap.addEntries(clickedSubmissionValuesMap.entries);
  }

  Future<dynamic> getSplashForm() {
    return repo.getSplashScreenForm();
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

  /// App background sync is called, in one of the possible scenarios
  /// 1. User clicks on the sync button
  /// 2. Post a successful project submission
  /// 3. Periodic timer initiates project sync
  /// 4. Network status changes to 'Active internet connection'
  callAppBackgroundSync(BuildContext context) {
    AppBackGroundSyncService appBackGroundSyncService =
        AppBackGroundSyncService();
    appBackGroundSyncService.execute(context);
  }

  Future<int> getNoOfEntriesNotSyncedYet() async {
    Box formMediaBox = await Hive.openBox(constants.formMediaBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));

    List<dynamic> hiveMediaCurrentEntries = [];
    hiveMediaCurrentEntries
        .addAll(formMediaBox.get(AppState.instance.userId.toLowerCase()) ?? []);

    /// For offline submission count
    Box submissionsBox = await Hive.openBox(constants.submissionsBox,
        encryptionCipher: HiveAesCipher(
            base64Decode(AppState.instance.hiveEncryptionKey.toString())));

    List<dynamic> submissionsBoxEntries = [];
    submissionsBoxEntries.addAll(
        submissionsBox.get(AppState.instance.userId.toLowerCase()) ?? []);

    return hiveMediaCurrentEntries.length + submissionsBoxEntries.length;
  }

  Color getTextColor() {
    return HexColor(AppState.instance.themeModel.textColor);
  }

  getAppBar(BuildContext context, {String? title, List<int>? iconList}) {
    FrameworkFormField? navTextField;
    List<FrameworkFormField> icons = [];
    List<Widget> iconWidgets = [];
    Widget? leadingIcon;

    if (currentForm.navBar.isEmpty &&
        title == null &&
        (iconList == null || iconList.isEmpty)) {
      return null;
    }

    for (var element in currentForm.navBar) {
      switch (element.uiType) {
        case constants.navButton:
          icons.add(element);
          break;
        case constants.navText:
          navTextField = element;
          break;
      }
    }

    if (iconList != null && iconList.isNotEmpty) {
      leadingIcon = _getIcons(iconList[0], null, context);
      for (int i = 1; i < iconList.length; i++) {
        iconWidgets.add(_getIcons(iconList[i], null, context));
      }
    } else if (icons.isNotEmpty) {
      leadingIcon = _getIcons(icons[0].type, icons[0].style, context);
      for (int i = 1; i < icons.length; i++) {
        iconWidgets.add(_getIcons(icons[i].type, icons[i].style, context));
      }
    }

    return AppBar(
      title: Center(
          child: Text(title ?? navTextField?.label ?? "",
              style: navTextField?.style != null
                  ? constants.applyStyle(navTextField!.style)
                  : constants.applyStyleV2(
                      color: AppState.instance.themeModel.secondaryColor))),
      iconTheme: IconThemeData(
          color: HexColor(AppState.instance.themeModel.secondaryColor)),
      elevation: constants.appBarElevation,
      backgroundColor: HexColor(AppState.instance.themeModel.primaryColor),
      leading: leadingIcon,
      actions: iconWidgets,
    );
  }

  Widget _getIcons(
      int iconType, FrameworkFormStyle? style, BuildContext context) {
    Color iconColor = style?.color != null
        ? HexColor(style!.color)
        : HexColor(AppState.instance.themeModel.secondaryColor);
    switch (iconType) {
      case 1:
        var icon = IconButton(
          icon: Icon(
            Icons.menu,
            color: iconColor,
          ),
          onPressed: () {
            if (scaffoldKey.currentState!.isDrawerOpen) {
              scaffoldKey.currentState?.openEndDrawer();
            } else {
              scaffoldKey.currentState?.openDrawer();
            }
          },
        );

        return icon;
      case 2:
        return IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: iconColor,
          ),
          onPressed: () async {
            if (!isLoading) {
              onBackPressed(context);
            }
          },
        );
      case 3:
        return IconButton(
          icon: Icon(
            Icons.arrow_forward,
            color: iconColor,
          ),
          onPressed: () {},
        );
      case 4:
        return IconButton(
          icon: Icon(
            Icons.home,
            color: iconColor,
          ),
          onPressed: () {},
        );
      case 5:
        return IconButton(
          icon: Icon(
            Icons.notifications,
            color: iconColor,
          ),
          onPressed: () {},
        );
      case 6:
        return IconButton(
          icon: Icon(
            Icons.logout,
            color: iconColor,
          ),
          onPressed: () {
            Provider.of<HomeViewModel>(context, listen: false).logOut(context);
          },
        );
      case 7:
        return SyncButtonWidget(
          style: style,
          viewModel: this,
        );
      case 8:
      default:
        return const SizedBox(
          width: 24.0,
        );
    }
  }

  Future<List<Submissions>> fetchDataListData(
      String entityId, BuildContext context) {
    return repo.fetchSubmissionList(entityId, null, true, context);
  }

  static FrameworkForm emptyFormData() {
    return FrameworkForm(
        formKey: '',
        formName: '',
        entityKey: '',
        parentEntityKey: '',
        formType: '',
        fields: [],
        buttons: [],
        navBar: [],
        menuDrawer: []);
  }
}
