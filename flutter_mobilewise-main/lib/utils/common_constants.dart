import 'package:flutter/material.dart';

import '../shared/model/framework_form.dart';
import 'app_state.dart';
import 'hex_color.dart';

const String appNameDev = 'mobileWISE - Dev';
const String appNameQa = 'mobileWISE - QA';
const String appNameProd = 'mobileWISE';

// Flavors
const String flavorNameDev = 'DEV';
const String flavorNameQa = 'QA';
const String flavorNameProd = 'PROD';

const String appId = '565258d5-9d84-404c-bbf5-6c92786b540a';
// const String appId = '66ca3b30-43f8-40e0-b672-bfd76cc039d4';

String baseUrl = '';
String authBaseUrl = '';
String s3BucketBaseUrl = '';
String accessKey = '';
String secretKey = '';
String bucket = '';
String region = '';
String s3Filefolder = 'mobilewise/${appId}/media';

const String screensConfigEndpoint = 'mobile-user-permissions';
const String formsConfigEndpoint = 'v1/mobile/transform';
const String formsSubmitEndpoint = 'data/submit';
const String fetchSubmissionsEndpoint = 'data/fetch-data';
const String getUploadUrlEndpoint = 'data/getsignedurl/';
const String loginEndpoint = 'mobile-login';
const String logoutEndpoint = 'mobile-logout';
const String refreshTokenEndpoint = 'mobile-refresh-token';
const String csrfTokenEndpoint = 'generate-csrf-token';
const String themeEndpoint = 'v1/applicationTheme';
const String updateAppVersionEndpoint = 'data/log-app-version';
const String changePasswordEndpoint = 'mobile-reset-password';
const String forgotPasswordEndpoint = 'forgot-password';
const String userPermissionsEndPoint = 'user-permissions';
const String entitySubmissionListEndPoint = 'v1/entitySubmissions/list';
const String entitySubmissionCreateEndPoint = 'v1/entitySubmissions/create';
const String mobileInstallationCountUpdate = 'v1/mobile/installation';

const String landingPage = 'LandingPage';
const String dataListDetails = 'dataListView';
const String loginPage = 'LoginPage';
const String splashScreenPage = 'SplashScreenPage';
const String previewScreenPage = 'Preview';

// App Background Sync interval in milliseconds (5 minutes)
const int appBackgroundSyncInterval = 300000;

// Media sync retries threshold
const int maxMediaRetries = 10;

//HeaderKeys
const String accept = 'Accept';
const String authorization = 'Authorization';
const String csrf = 'Csrf-Token';
const String deviceID = 'DeviceId';
const String headerJson = 'application/json';
const String headerContentType = 'Content-type';
const String refreshToken = 'refreshToken';
const String userNameHeader = 'userName';
const String applicationId = 'applicationId';


// Time durations
const int splashDuration = 3; // Seconds
const int postSubmissionSyncDelayDuration = 500; // Milliseconds

// Navigation routes for the app
const String initialRoute = '/';
const String permissionsRoute = '/permissions';
const String loginRoute = '/login';
const String forgotPasswordRoute = '/forgotPassword';
const String homeRoute = '/home';
const String formRoute = '/form';
const String submittedRoute = '/submitted';
const String imagePreviewRoute = '/imagePreview';
const String aboutRoute = '/about';
const String changePasswordRoute = '/changePassword';
const String previewScreen = '/previewScreen';

// Colors
const int primaryColor = 0xFFFBD002;
const int appBarHeaderColor = 0xFF565656;
const int formFieldBackgroundColor = 0xFFEBEBEB;
const int formFieldLabelColor = 0xFF8E8D8D;
const int greySeparatorColor = 0xFFDEDEDE;
const int clickableTextColor = 0xFF4B92B8;
const int previewSeparatorColor = 0xFFDBDBDB;
const int slaTextColor = 0xFF565656;
const int collapsibleArrowColor = 0xFFC20908;
const int colorWhite = 0xFFFFFFFF;

// Icons
// const String appIcon = 'assets/images/logo.png';
const String appIcon = 'assets/images/logo.png';
const String stanleyIcon = 'assets/images/logo_bottom.png';
const String greenTick = 'assets/images/green_tick.png';
const String camera = 'assets/images/camera.png';
const String defaultImage = 'assets/images/default_image.png';
const String calendar = 'assets/images/calendar.png';
const String trash = 'assets/images/trash.png';
const String addItemIcon = 'assets/images/add_item.png';
const String filterIcon = 'assets/images/filter.png';
const String alertBlue = 'assets/images/alert_blue.png';
const String calendarGrey = 'assets/images/calendar_grey.png';
const String person = 'assets/images/person.png';
const String infoCircleIcon = 'assets/images/info_circle.png';
const String dropDown = 'assets/images/drop_down.png';

// Paddings
const double largePadding = 32;
const double mediumPadding = 16;
const double smallPadding = 8;
const double xSmallPadding = 4;

// Dimensions
const double appDrawerHeaderHeight = 150;
const double buttonHeight = 48;
const double appBarHeaderHeight = 160;
const double appBarHeaderIconDimension = 26;
const double formButtonBarHeight = 82;
const double horizontalSeparatorHeight = 1;
const double formDropdownMenuMaxHeight = 350;
const double formFieldHeight = 105;
const double cameraIconDimension = 36;
const double cameraPlaceholderImageHeight = 220;
const double maxFileThumbnailHeight = 180;
const double minFileThumbnailHeight = 42;
const double fileThumbnailListHeight = 110;
const double fileThumbnailHeight = 80;
const double fileThumbnailWidth = 120;
const double mimeTypeImageHeight = 60;
const double mimeTypeImageWidth = 75;
const double networkImageErrorPlaceholderWidth = 160;
const double closeIconDimension = 16;
const double dropdownItemHeight = 40;
const double addItemIconDimension = 46;
const double permissionScreenTopBarHeight = 175;
const double permissionIconDimension = 46;
const double permissionTopBarIconHeight = 56;
const double permissionTopBarIconWidth = 175;
const double markerIconDimension = 36;
const double timelineCircleWidth = 18;
const double timelineRectangleWidth = 6;
const double dropdownHeight = 101;
const double timelineItemHeight = 80;
const double searchableDropdownItemHeight = 50;
const double searchableDropdownMaxHeight = 250;
const double infoCircleIconDimension = 22;
const double filterIconDimension = 38;
const double mediumSpaceHeight = 12;
const double xSmallSpaceHeight = 5;
const double xxSmallSpaceHeight = 2.5;

// Elevations
const double appBarElevation = 4;
const double formComponentsElevation = 4;

// String resources
const String userName = 'Username';
const String passwordString = 'Password';
const String loginString = 'LOGIN';
const String forgotPasswordString = 'Forgot Password?';
const String emptyEmailErrorMsg = 'Email cannot be empty';
const String invalidEmailErrorMsg = 'Invalid email';
const String invalidBranchErrorMsg = 'Invalid branch';
const String mandatoryPhoneNumberErrorMsg = 'Phone number is a mandatory field';
const String invalidPhoneNumberErrorMsg = 'Invalid phone number';
const String emptyPasswordErrorMsg = 'Password cannot be empty';
const String emptyErrorMsg = 'cannot be empty';
const String invalidCredentialsErrorMsg = 'Invalid credentials';
const String emptyFilterErrorMsg =
    'Please select a filtering criteria before applying filters';
const String resetPasswordHeading = 'Reset Password';
const String reset = 'Reset';
const String appVersionLabel = 'App Version:';
const String currentlyUnderDev = 'Currently under development';
const String search = 'Search';
const String success = 'Success';
const String offlineSuccess =
    'Successfully submitted offline. Will be synced once active internet is available';
const String finish = 'Finish';
const String defaultKey = 'default';
const String genericErrorMsg = 'Something went wrong, please try later';
const String formErrorMsg =
    'Could not create submission request, please check form data';
const String permissionsErrorMsg = 'Please grant permissions before proceeding';
const String imageCaptureErrorMessage = 'Did not capture image';
const String fileCaptureErrorMessage = 'Did not capture file';
const String maxImageCaptureMessage =
    'Cannot capture any more photographs, limit reached';
const String maxFileCaptureMessage =
    'Cannot upload any more files, limit reached';
const String initializeLocationMessage =
    'Please wait as we fetch your location';
const String initializeLocationServiceMessage =
    'Please turn on your location service';
const String grantLocationPermission =
    'Please allow the app to access the device\'s location';
const String allowPermissions = 'ALLOW PERMISSIONS';
const String confirmLocation = 'CONFIRM LOCATION';
const String addItemErrorMsg =
    'Please enter all mandatory fields before adding a new entry';
const String selectStartDate = 'Select Start Date';
const String selectEndDate = 'Select End Date';
const String preSyncMessage = 'App sync has started';
const String postSyncMessage = 'App sync has ended';
const String noFormsErrorMessage = 'No forms available for this module';
const String noEvents = 'No events to show';
const String submit = 'Submit';
const String logoutErrorMsg = 'Cannot logout, please try again later';
const String resetPasswordErrorMsg =
    'Unable to reset password. Please try later';
const String attachmentsNotAvailableMsg = 'No attachments available';

const String imageDialogCamera = 'Click from Camera';
const String imageDialogGallery = 'Upload from Gallery';
const String imageDialogCancel = 'Cancel';

const String eventData = 'eventData';
const String timeStamp = 'timeStamp';
const String reportedTs = 'timeStamp';

const String iosIdChannel = "unique_ios_id_channel";
const String getUniqueIdForIOS = "getUniqueIdForIOS";

const String getUserName = "getUserName";
const String getAuth64 = "getAuth64";
const String username = "username";
const String auth64 = "auth64";
const String fcmToken = "fcmToken";

// API Types
const String getAPI = 'GET';
const String postAPI = 'POST';

// Permissions
const String locationPermissionHeading = 'Location';
const String locationPermissionSubHeading =
    'Allow location permission to fetch '
    'the current location of the field technician. Please make sure your \'Location services\' are turned on.';
const String cameraPermissionHeading = 'Camera';
const String cameraPermissionSubHeading = 'Allow camera permission to take '
    'pictures';
const String serverDown =
    'Server may be down. Please open a ticket or contact your local Super Tech regarding this issue.';
const String loggedInSucc = 'Logged in successfully';
const String loggedInFailedBecauseOfRole = 'Cannot login, invalid user role';
const String noNetworkAvailability =
    'Please check your network connection, no internet available';
const String noForceSyncErrorMsg =
    'Cannot force sync as app sync is in progress. Please wait and try again.';
const String lessThanZeroNotAllowed = 'This value cannot be less than 0';
const String toManyLoginAttempts =
    'Too many login attempts. Please wait for 15 mins and try again.';
const String noBranchIdAvailable =
    'Branch ID not available, please try again later';
const String addBranchError = 'Cannot add branch, please try again later';
const String passwordChangeMessage = 'Password changed successfully';
const String passwordResetMessage = 'Unable to reset password';
const int lockOutTime = 900; // 15 minutes * 60 sec
const int lockOutAttempts = 10;

// Form Field UI Type
const String dropdown = 'dropdown';
const String edittext = 'textbox';
const String subform = 'subform';
const String image = 'image';
const String date = 'date';
const String button = 'button';
const String singleSelectCheckbox = 'singleselectcheckbox';
const String previewFormType = 'PREVIEW';
const String headerKeyPrefix = 'header_';
const String dataList = 'DataList';
const String column = 'column';
const String row = 'row';
const String smallestRow = 'smallest_row';
const String dataListText = 'data_list_text';
const String separator = 'separator';
const String tabs = 'tabs';
const String geotag = 'geotag';
const String timeline = 'timeline';
const String radio = 'radio';
const String dateRange = 'date_range';
const String previewGroup = 'preview_group';
const String historyText = 'history_text';
const String text = 'text';
const String numericEdittext = 'numeric_textbox';
const String address = 'address';
const String scanner = 'scanner';
const String timePreview = 'time_preview';
const String imageUploader = 'imageUploader';
const String dataListCollapsible = 'data_list_collapsible';
const String navText = 'NavText';
const String navButton = 'NavButton';
const String filePicker = "filepicker";
const String fingerPrint = "fingerPrint";
const String dataListImagePicker = "image_picker";
const String dataListFilePicker = "file_picker";

const String sortByFilter = 'filter#sort_by';
const String dateRangeFilter = 'filter#date_range';
const String sortByCustomer = 'Customer Name';
const String sortByDate = 'Date';
const String customerKey = 'customer';

const String newPassword = 'New Password';
const String confirmPassword = 'Confirm Password';
const String confirmPasswordError = 'Password confirmation do not match';

// Form Field data types
const String string = 'string';
const String number = 'int';
const String float = 'double';

// Drawer Items
const String about = 'About';
const String logout = 'Logout';
const String forceSync = 'Force Sync';
const String changePassword = 'Change Password';

const String bold = 'bold';
const String columnOrientationRight = 'right';

// Text Styles
TextStyle resetPasswordHeadingTextStyle = const TextStyle(
  fontSize: 28,
  color: Colors.black,
  fontWeight: FontWeight.w500,
);
TextStyle dataListLabelTextStyle = const TextStyle(
  fontSize: 26,
  color: Colors.black,
  fontWeight: FontWeight.w500,
);
TextStyle largeBlackTextStyle = const TextStyle(
  fontSize: 18,
  color: Colors.black,
);
TextStyle normalBlackTextStyle = const TextStyle(
  fontSize: 16,
  color: Colors.black,
);
TextStyle normalTextStyle = TextStyle(
    fontSize: 16, color: HexColor(AppState.instance.themeModel.textColor));
TextStyle normalBoldBlackTextStyle = const TextStyle(
  fontSize: 16,
  color: Colors.black,
  fontWeight: FontWeight.w500,
);
TextStyle mNormalBoldBlackTextStyle = const TextStyle(
  fontSize: 18,
  color: Colors.black,
  fontWeight: FontWeight.w500,
);
TextStyle largeBoldBlackTextStyle = const TextStyle(
  fontSize: 20,
  color: Colors.black,
  fontWeight: FontWeight.w500,
);
TextStyle normalGreyTextStyle = const TextStyle(
  fontSize: 16,
  color: Color(formFieldLabelColor),
);
TextStyle normalClickableTextStyle = const TextStyle(
  fontSize: 16,
  color: Color(clickableTextColor),
);
TextStyle mediumGreyTextStyle = const TextStyle(
  fontSize: 14,
  color: Color(formFieldLabelColor),
);
TextStyle mediumTextStyle = TextStyle(
    fontSize: 14, color: HexColor(AppState.instance.themeModel.textColor));
TextStyle mediumBlackTextStyle = const TextStyle(
  fontSize: 14,
  color: Colors.black,
);
TextStyle smallGreyTextStyle = const TextStyle(
  fontSize: 13,
  color: Color(formFieldLabelColor),
);
TextStyle normalRedTextStyle = const TextStyle(
  fontSize: 16,
  color: Colors.red,
);
TextStyle smallRedTextStyle = const TextStyle(
  fontSize: 13,
  color: Colors.red,
);
TextStyle buttonTextStyle = TextStyle(
  fontSize: 18,
  color: HexColor(AppState.instance.themeModel.secondaryColor),
  fontWeight: FontWeight.w500,
);
TextStyle appBarListTileTextStyle = const TextStyle(
  fontSize: 16,
  color: Colors.black,
  fontWeight: FontWeight.w400,
);
TextStyle appBarHeaderTextStyle = const TextStyle(
  fontSize: 22,
  color: Colors.white,
  fontWeight: FontWeight.w500,
);
TextStyle tabSelectedTextStyle = const TextStyle(
  fontSize: 18,
  color: Colors.black,
  fontWeight: FontWeight.w500,
);
TextStyle tabUnselectedTextStyle = const TextStyle(
  fontSize: 18,
  color: Color(formFieldLabelColor),
  fontWeight: FontWeight.w500,
);
TextStyle sSmallGreyTextStyle = const TextStyle(
  fontSize: 8,
  color: Color(formFieldLabelColor),
);
TextStyle lMediumBlackTextStyle = const TextStyle(
    fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400);
TextStyle lSmallRedTextStyle = const TextStyle(
    fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500);
TextStyle mNormalGreyTextStyle = const TextStyle(
  fontSize: 12,
  color: Color(slaTextColor),
);
TextStyle mSmallBlackTextStyle = const TextStyle(
  fontSize: 12,
  color: Colors.black,
  fontWeight: FontWeight.w400,
);

applyAppBarHeaderTextStyle() {
  return TextStyle(
    fontSize: 22,
    color: HexColor(AppState.instance.themeModel.secondaryColor),
    fontWeight: FontWeight.w500,
  );
}

applyStyle(FrameworkFormStyle? style) {
  return TextStyle(
    fontWeight: (style != null && style!.bold == true)
        ? FontWeight.bold
        : FontWeight.normal,
    decoration: (style != null && style!.underline == true)
        ? TextDecoration.underline
        : TextDecoration.none,
    decorationColor: (style != null && style!.color.isNotEmpty)
        ? HexColor(style!.color)
        : HexColor(AppState.instance.themeModel.textColor),
    fontSize: (style != null) ? double.parse('${style?.size}') : 16.0,
    fontStyle: (style != null && style!.italics == true)
        ? FontStyle.italic
        : FontStyle.normal,
    color: (style != null && style!.color.isNotEmpty)
        ? HexColor(style!.color)
        : HexColor(AppState.instance.themeModel.textColor),
  );
}

mandatoryField(FrameworkFormField field) {
  return RichText(
    text: TextSpan(
      text: field.label,
      style: applyStyle(field.style),
      children: <TextSpan>[
        // Red * to show if the field is mandatory
        TextSpan(
          text: field.isMandatory ? ' *' : '',
          style: normalRedTextStyle,
        ),
      ],
    ),
  );
}

applyStyleV2(
    {bool bold = false,
    bool underline = false,
    bool italics = false,
    String? color,
    int size = 16}) {
  color = color ?? AppState.instance.themeModel.textColor;
  return TextStyle(
      fontWeight: bold == true ? FontWeight.bold : FontWeight.normal,
      decoration:
          underline == true ? TextDecoration.underline : TextDecoration.none,
      decorationColor: HexColor(color),
      fontSize: double.parse('$size'),
      fontStyle: italics ? FontStyle.italic : FontStyle.normal,
      color: HexColor(color));
}

// Button Styles
ButtonStyle buttonStyle({required Color backgroundColor}) {
  return ElevatedButton.styleFrom(
    backgroundColor: backgroundColor,
    shape: const StadiumBorder(),
    elevation: formComponentsElevation,
  );
}

// Shared Preferences
const String preferenceTypeString = 'string';
const String preferenceTypeStringList = 'stringList';
const String preferenceTypeInt = 'int';
const String preferenceTypeBool = 'bool';
const String preferenceTypeDouble = 'double';
const String preferenceIsLoggedIn = 'isLoggedIn';
const String preferenceLoginAttempts = 'loginAttempts';
const String preferenceLastLoginTime = 'LastLoginAttemptTime';
const String preferenceIsFirstTimeUse = 'isFirstTimeUse';

// Secured storage keys
const String firstAppLaunch = 'firstAppLaunch';
const String hiveEncryptionKey = 'hiveKey';
const String preferenceUserId = 'userId';
const String preferenceUsername = 'username';
const String preferenceJwtModelString = 'jwtModelString';
const String preferenceLastLogin = 'lastLogin';
const String authToken = "token";
const String csrfToken = "csrf";
const String theme = "theme";
const String themePrimaryColor = "themePrimaryColor";

// JSONs
const String screensJson = 'assets/jsons/home.json';
const String failuresJson = 'assets/jsons/failures.json';
const String reportFailureJson = 'assets/jsons/report_failure_view.json';
const String trackFailureJson = 'assets/jsons/track_failure_view.json';
const String formsJson = 'assets/jsons/forms_api.json';

// Circular Progress Indicator
Widget getIndicator() {
  return Center(
    child: CircularProgressIndicator(
      strokeWidth: 5,
      color: HexColor(AppState.instance.themeModel.primaryColor),
    ),
  );
}

Widget blackIndicator = const Center(
  child: CircularProgressIndicator(
    strokeWidth: 5,
    color: Colors.black,
  ),
);

BoxDecoration dropdownContainerDecoration = BoxDecoration(
  border: Border.all(
    color: const Color(formFieldBackgroundColor),
  ),
  borderRadius: const BorderRadius.all(
    Radius.circular(10),
  ),
  color: const Color(formFieldBackgroundColor),
);

BoxDecoration networkImageContainerDecoration = BoxDecoration(
  border: Border.all(
    color: Colors.white,
  ),
  borderRadius: const BorderRadius.all(
    Radius.circular(10),
  ),
  color: Colors.white,
);

BoxDecoration dropdownItemDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(
      color: const Color(formFieldBackgroundColor),
    ),
    borderRadius: const BorderRadius.all(
      Radius.circular(10),
    ));

BoxDecoration yellowDropdownContainerDecoration = BoxDecoration(
  border: Border.all(
    color: const Color(primaryColor),
  ),
  borderRadius: const BorderRadius.all(
    Radius.circular(10),
  ),
  color: const Color(primaryColor),
);

BorderRadius materialBorderRadius = const BorderRadius.all(
  Radius.circular(10),
);

// Hive Box Names
const String homeScreenConfigBox = 'homeScreenConfigBox';
const String formMediaBox = 'formMediaBox';
const String formsBox = 'formsBox';
const String fetchedSubmissionsBox = 'fetchedSubmissionsBox';
const String submissionsBox = 'submissionsBox';
const String rejectedSubmissionsBox = 'rejectedSubmissionsBox';
const String dropdownValuesBox = 'dropdownValuesBox';

// Hive Type Adapter IDs
// NOTE - DO NOT CHANGE THESE VALUES IN ANY CASE
const int screenConfigTypeAdapterId = 0;
const int formMediaTypeAdapterId = 1;
const int serverFormTypeAdapterId = 2;
const int fetchedSubmissionsTypeAdapterId = 3;
const int submissionsTypeAdapterId = 4;
const int entitiesTypeAdapterId = 5;
const int submissionFieldTypeAdapterId = 6;
const int rejectedSubmissionsTypeAdapterId = 7;
