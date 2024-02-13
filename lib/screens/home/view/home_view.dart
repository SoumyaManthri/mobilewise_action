import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/screens/forms/view/form_field_v2/app_drawer_form_view.dart';
import 'package:provider/provider.dart';

import '../../../screens/home/view_model/home_view_model.dart';
import '../../../shared/event/app_events.dart';
import '../../../utils/app_state.dart';
import '../../../utils/biometric_auth.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/hex_color.dart';
import '../../../utils/util.dart';
import '../../forms/view/form_fragment_view.dart';
import '../../forms/view_model/form_view_model.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({Key? key}) : super(key: key);

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  late HomeViewModel viewModel;
  late FormViewModel formViewModel;
  StreamSubscription? postSubmissionEventSubscription;
  StreamSubscription? networkChangeSubscription;
  SupportState _supportState = SupportState.unknown;

  @override
  void initState() {
    BiometricAuth.instance.auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState =
              isSupported ? SupportState.supported : SupportState.unsupported),
        );
    viewModel = Provider.of<HomeViewModel>(context, listen: false);
    formViewModel = Provider.of<FormViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.checkTokenValidation(context);
      await viewModel.getTheme();
      await viewModel.fetchUserPermissions(context);
      await viewModel.fetchForms(context);
      final bool isItfromLogin =
          ModalRoute.of(context)!.settings.arguments as bool;

      bool isBiometricEnabled = await viewModel.getIsBioMetricEnabled();
      formViewModel.formId = constants.landingPage;
      await formViewModel.initializeForm();
      await formViewModel.findCurrentForm(
          AppState.instance.formsTypesWithKey[constants.landingPage]!);
      viewModel.isLoading = false;
      /*viewModel.updateAppVersionOnBackend();*/
      if (_supportState == SupportState.supported &&
          isBiometricEnabled &&
          !isItfromLogin) {
        BiometricAuth.instance.checkBiometrics(context);
      }
    });
    postSubmissionEventSubscription = AppState.instance.eventBus
        .on<SuccessfulProjectSubmissionEvent>()
        .listen((event) {
      /// Event to refresh the sync count
      AppState.instance.eventBus.fire(RefreshSyncCount());

      /// Calling app background sync after a project has been submitted successfully
      // viewModel.callAppBackgroundSync(context);
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

    /// Periodic app background sync set
    /* Timer.periodic(
        const Duration(milliseconds: constants.appBackgroundSyncInterval),
        (timer) async {
      Util.instance.logMessage('Home View', 'Auto sync called!');
      viewModel.callAppBackgroundSync(context);
    });*/
    super.initState();
  }

  @override
  void dispose() {
    if (postSubmissionEventSubscription != null) {
      postSubmissionEventSubscription!.cancel();
    }
    if (networkChangeSubscription != null) {
      networkChangeSubscription!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (_, model, child) {
        if (model.isLoading) {
          return child ?? const SizedBox();
        }

        return Scaffold(
          appBar: formViewModel.getAppBar(context),
          drawer: formViewModel.currentForm.menuDrawer.isNotEmpty
              ? AppDrawerWidget(
                  menuList: formViewModel.currentForm.menuDrawer,
                  viewModel: formViewModel,
                )
              : null,
          resizeToAvoidBottomInset: false,
          body: Container(
            key: formViewModel.scaffoldKey,
            color: HexColor(AppState.instance.themeModel.backgroundColor),
            child: SafeArea(
              child: formViewModel.currentForm.formKey.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: FormFragmentWidget(
                            viewModel: formViewModel,
                          ),
                        ),
                      ],
                    )
                  : SizedBox() /*Center(
                      child: Text(
                        constants.noFormsErrorMessage,
                        style: constants.normalGreyTextStyle,
                      ),
                    )*/
              ,
            ),
          ),
        );
      },
      child: PopScope(
        canPop: !formViewModel.isLoading,
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: HexColor(AppState.instance.themeModel.backgroundColor),
            child: constants.getIndicator(),
          ),
        ),
      ),
    );
  }
}
