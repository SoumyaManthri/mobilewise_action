import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobilewise/utils/hex_color.dart';
import '/screens/forms/view/form_preview_fragment_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'flavor_config.dart';
import 'locator.dart';
import 'screens/about/view/about_view.dart';
import 'screens/about/view_model/about_view_model.dart';
import 'screens/change_password/repository/change_password_repo.dart';
import 'screens/change_password/view/change_password.dart';
import 'screens/change_password/view_model/change_password_view_model.dart';
import 'screens/forgot_password/repository/forgot_password_repo.dart';
import 'screens/forgot_password/view/forgot_password.dart';
import 'screens/forgot_password/view_model/forgot_password_view_model.dart';
import 'screens/forms/model/entity_instance_model.dart';
import 'screens/forms/model/form_media_model.dart';
import 'screens/forms/model/offline_submission_model.dart';
import 'screens/forms/model/server_form_model.dart';
import 'screens/forms/model/server_submission.dart';
import 'screens/forms/model/submission_field_model.dart';
import 'screens/forms/repository/form_repo.dart';
import 'screens/forms/view/form_view.dart';
import 'screens/forms/view_model/edittext_view_model.dart';
import 'screens/forms/view_model/form_view_model.dart';
import 'screens/home/repository/home_repo.dart';
import 'screens/home/model/screen_config_model.dart';
import 'screens/home/view/home_view.dart';
import 'screens/home/view_model/home_view_model.dart';
import 'screens/image_preview/view/image_preview_screen_widget.dart';
import 'screens/login/repository/login_repo.dart';
import 'screens/login/view/login_view.dart';
import 'screens/login/view_model/login_view_model.dart';
import 'screens/permissions/view/permissions_view.dart';
import 'screens/permissions/view_model/permissions_view_model.dart';
import 'screens/splash/view/splash_view.dart';
import 'screens/splash/view_model/splash_view_model.dart';
import 'screens/successful_submission/view/successful_submission_screen_widget.dart';
import 'utils/app_state.dart';
import 'utils/common_constants.dart' as constants;
import 'utils/secured_storage_util.dart';
import 'utils/shared_preference_util.dart';
import 'utils/util.dart';

void mainCommon(FlavorConfig flavorConfig) async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Setting the orientation of the app to portrait
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  /// Initializing Hive
  await _initializeHive();

  /// Initialize base URLs based on build flavor (using environment files)
  Util.instance.initBaseUrls();

  /// Init Service Locator
  setupLocator();

  /// iOS Specific code
  /// 1. Check if this is the first time the app is being run
  /// 2. If yes, then delete the user data from the secure storage
  /// 3. If not, continue
  if (Platform.isIOS) {
    await _clearUserDataForIos();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SplashViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => PermissionsViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(repo: locator<LoginRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(repo: locator<HomeRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => FormViewModel(repo: locator<FormRepository>(), loginRepo: locator<LoginRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => AboutViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => EditTextViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChangePasswordViewModel(
              repo: locator<ChangePasswordRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ForgotPasswordViewModel(
              repo: locator<ForgotPasswordRepository>()),
        ),
      ],
      child: const MobileWISEApp(),
    ),
  );
}

/// Initializing Hive
_initializeHive() async {
  /// Getting the storage directory for the Hive DB
  final appDocumentDirectory = await getApplicationDocumentsDirectory();

  /// Initializing the Hive DB
  Hive
    ..initFlutter(appDocumentDirectory.path)
    ..registerAdapter(ScreensConfigModelAdapter())
    ..registerAdapter(FormMediaModelAdapter())
    ..registerAdapter(ServerFormModelAdapter())
    ..registerAdapter(ServerSubmissionAdapter())
    ..registerAdapter(OfflineSubmissionModelAdapter())
    ..registerAdapter(EntityInstanceAdapter())
    ..registerAdapter(SubmissionFieldAdapter());

  /// Checking if an encryption key exists
  /// If not, we are creating one and saving it to secure storage
  /// If it exists, fetching it from secure storage and saving to app state
  bool encryptionKeyExists = await SecuredStorageUtil.instance
      .containsKeyInSecureData(constants.hiveEncryptionKey);
  if (encryptionKeyExists) {
    /// Retrieve from secured storage and add to AppState
    AppState.instance.hiveEncryptionKey = await SecuredStorageUtil.instance
        .readSecureData(constants.hiveEncryptionKey);
  } else {
    /// Generate new encryption key, save to secured storage, and add to AppState
    var key = Hive.generateSecureKey();
    String? encryptionKey = base64UrlEncode(key);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.hiveEncryptionKey, encryptionKey);
    AppState.instance.hiveEncryptionKey = encryptionKey;
  }
}

class MobileWISEApp extends StatelessWidget {
  const MobileWISEApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: Util.instance.getAppNameBasedOnFlavor(),
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: HexColor(AppState.instance.themeModel.primaryColor),
      ),
      initialRoute: constants.initialRoute,
      routes: {
        constants.initialRoute: (context) => const SplashScreenWidget(),
        constants.permissionsRoute: (context) =>
            const PermissionsScreenWidget(),
        constants.loginRoute: (context) => const LoginScreenWidget(),
        constants.homeRoute: (context) => const HomeScreenWidget(),
        constants.formRoute: (context) => const FormScreenWidget(),
        constants.submittedRoute: (context) =>
            const SuccessfulSubmissionScreenWidget(),
        constants.imagePreviewRoute: (context) =>
            const ImagePreviewScreenWidget(),
        constants.aboutRoute: (context) => const AboutScreenWidget(),
        constants.changePasswordRoute: (context) =>
            const ChangePasswordWidget(),
        constants.forgotPasswordRoute: (context) => const ForgotPasswordWidget(),
        constants.previewScreen: (context) =>
        const FormPreviewFragmentWidget(),
      },
    );
  }
}

_clearUserDataForIos() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  bool isFirstTimeUse =
      preferences.getBool(constants.preferenceIsFirstTimeUse) ?? true;

  if (isFirstTimeUse) {
    await _clearUserDataForFirstTimeUse();
  }
}

_clearUserDataForFirstTimeUse() async {
  await SharedPreferenceUtil.instance.setPreferenceValue(
      constants.preferenceIsLoggedIn, false, constants.preferenceTypeBool);
  await SharedPreferenceUtil.instance.setPreferenceValue(
      constants.preferenceIsFirstTimeUse, false, constants.preferenceTypeBool);
  await SecuredStorageUtil.instance
      .writeSecureData(constants.preferenceUserId, '');
  await SecuredStorageUtil.instance
      .writeSecureData(constants.preferenceUsername, '');
  await SecuredStorageUtil.instance
      .writeSecureData(constants.preferenceJwtModelString, '');
  await SecuredStorageUtil.instance
      .writeSecureData(constants.preferenceLastLogin, '');
}
