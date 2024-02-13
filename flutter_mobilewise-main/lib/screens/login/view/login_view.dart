import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/utils/hex_color.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/navigation_util.dart';
import '../../../utils/util.dart';
import '../../forms/view/form_fragment_view.dart';
import '../../forms/view_model/form_view_model.dart';

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({Key? key}) : super(key: key);

  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget> {
  late FormViewModel formViewModel;
  StreamSubscription? networkChangeSubscription;

  @override
  void initState() {
    super.initState();
    formViewModel = Provider.of<FormViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      formViewModel.getTheme();
      await formViewModel.fetchForms(context);
      formViewModel.formId = constants.loginPage;
      await formViewModel.initializeForm();
      if (AppState.instance.formsTypesWithKey[constants.loginPage] != null) {
        await formViewModel.findCurrentForm(
            AppState.instance.formsTypesWithKey[constants.loginPage]!);
      }
      AppState.instance.formTempMap.clear();
      formViewModel.isLoading = false;
    });

    networkChangeSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        /// Connected to a mobile network or wifi network
        Util.instance.logMessage('Home View', 'Active internet available!');
      } else {
        /// No active internet connection
        Util.instance.logMessage('Home View', 'Disconnected from internet!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormViewModel>(
      builder: (_, model, child) {
        if (model.isLoading) {
          return child ?? const SizedBox();
        }

        return Scaffold(
          body: Container(
            color: HexColor(AppState.instance.themeModel.backgroundColor),
            child: SafeArea(
              child: formViewModel.currentForm.formKey.isNotEmpty
                  ? FormFragmentWidget(
                      viewModel: formViewModel,
                    )
                  : const SizedBox(),
            ),
          ),
        );
      },
      child: WillPopScope(
        onWillPop: () => NavigationUtil.instance
            .avoidBackPressWhenLoadingViewModel(formViewModel.isLoading),
        child: Scaffold(
          body: Container(
            color: Colors.white,
            child: constants.getIndicator(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (networkChangeSubscription != null) {
      networkChangeSubscription!.cancel();
    }
    super.dispose();
  }
}
