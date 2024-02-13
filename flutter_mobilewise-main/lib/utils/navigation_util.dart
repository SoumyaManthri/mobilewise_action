import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/shared/model/framework_form.dart';

import '../screens/successful_submission/model/successful_submission_arguments.dart';
import '../shared/model/form_arguments.dart';
import '../shared/model/form_preview_arguments.dart';
import '../shared/model/image_preview_arguments.dart';
import '../utils/common_constants.dart' as constants;

class NavigationUtil {
  static NavigationUtil? _instance;

  NavigationUtil._();

  static NavigationUtil get instance => _instance ??= NavigationUtil._();

  navigateToPermissionsScreenAndPop(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, constants.permissionsRoute, (route) => false);
  }

  navigateToLoginScreen(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, constants.loginRoute, (route) => false);
  }

  navigateToForgotPasswordScreen(BuildContext context) {
    Navigator.pushNamed(context, constants.forgotPasswordRoute);
  }

  navigateToHomeScreen(BuildContext context, bool isFromLogin) {
    Navigator.pushNamedAndRemoveUntil(
        context, constants.homeRoute, (route) => false,arguments: isFromLogin,);
  }

  navigateToFormScreen(BuildContext context, String formId) {
    Navigator.pushNamed(
      context,
      constants.formRoute,
      arguments: FormArguments(
        formId,
      ),
    );
  }

  navigateToFormSubmittedScreen(BuildContext context, String message) {
    Navigator.pushNamed(
      context,
      constants.submittedRoute,
      arguments: SuccessfulSubmissionArguments(
        message,
      ),
    );
  }

  navigateToImagePreviewScreen(
      BuildContext context, String? imagePath, String? imageUrl) {
    Navigator.pushNamed(context, constants.imagePreviewRoute,
        arguments: ImagePreviewArguments(imagePath, imageUrl));
  }

  navigateToAboutScreen(BuildContext context) {
    Navigator.pushNamed(context, constants.aboutRoute);
  }

  navigateToChangePasswordScreen(BuildContext context) {
    Navigator.pushNamed(context, constants.changePasswordRoute);
  }

  Future<bool> avoidBackPressWhenLoadingViewModel(bool isLoading) async {
    if (isLoading) {
      return false;
    }
    return true;
  }

  navigateToFormPreviewScreen(BuildContext context, FrameworkFormField button) {
    Navigator.pushNamed(
      context,
      constants.previewScreen,
      arguments: FormPreviewArguments(button),
    );
  }
}
