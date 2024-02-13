import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/shared_preference_util.dart';
import '../../../utils/common_constants.dart' as constants;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

import '../shared/model/framework_form.dart';

class BiometricAuth {
  static BiometricAuth? _instance;

  BiometricAuth._();

  static BiometricAuth get instance => _instance ??= BiometricAuth._();

  final LocalAuthentication auth = LocalAuthentication();

  Future<void> checkBiometrics(BuildContext context) async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!context.mounted) {
      _dialogBuilder(context);
      // return;
    }
    if (canCheckBiometrics) {
      _authenticate(context);
    }
  }

  Future<void> _authenticate(BuildContext context) async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Authenticate is required to use this app',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      print(e);
      return;
    }catch (e) {
      // Catch any exceptions that occur during authentication
      print('Error: $e');
      // Handle the error here
    }
    if (!authenticated) {
      _dialogBuilder(context);
      return;
    }
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Locked'),
          content: const Text(
            'Authenticate is required to use this app',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Unlock'),
              onPressed: () {
                checkBiometrics(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future updateBiometricIsEnabled(FrameworkForm form) async{
    bool isUpdated = false;
    for (FrameworkFormField field in form.fields) {
      if(field.uiType != null && field.uiType.isNotEmpty && field.uiType == constants.fingerPrint){
        await SharedPreferenceUtil.instance.setPreferenceValue(
            constants.fingerPrint, true, constants.preferenceTypeBool);
        isUpdated = true;
        break;
      }
    }

    if(!isUpdated){
      await SharedPreferenceUtil.instance.setPreferenceValue(
          constants.fingerPrint, false, constants.preferenceTypeBool);
    }
  }
}
