import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_protector/screen_protector.dart';

import '../../../screens/splash/view_model/splash_view_model.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/hex_color.dart';
import '../../../utils/network_util.dart';
import '../../forms/view/form_fragment_view.dart';
import '../../forms/view_model/form_view_model.dart';

class SplashScreenWidget extends StatefulWidget {
  const SplashScreenWidget({Key? key}) : super(key: key);

  @override
  State<SplashScreenWidget> createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends State<SplashScreenWidget> {
  late SplashViewModel viewModel;
  late FormViewModel formViewModel;

  @override
  void initState() {
    viewModel = Provider.of<SplashViewModel>(context, listen: false);
    formViewModel = Provider.of<FormViewModel>(context, listen: false);
    viewModel.formViewModel = formViewModel;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      /*if(Platform.isIOS) {
        _restrictScreenshotForIos();
      }*/
      formViewModel.isLoading = true;
      await formViewModel.getSplashForm();
      await formViewModel.getTheme();
      formViewModel.formId = constants.splashScreenPage;
      await formViewModel.initializeForm();
      if (AppState.instance.formsTypesWithKey[constants.splashScreenPage] !=
          null) {
        await formViewModel.findCurrentForm(
            AppState.instance.formsTypesWithKey[constants.splashScreenPage]!);
        formViewModel.backstack.remove(formViewModel.currentForm);
        formViewModel.isLoading = false;
      }
      formViewModel.isLoading = false;

      networkUtils.startTrackingConnection();

      viewModel.updateDownloadCount(context);

      viewModel.checkPermissionsAndNavigate(context);
    });
    super.initState();
  }

  /// Avoiding screenshot on iOS
  _restrictScreenshotForIos() async {
    await ScreenProtector.preventScreenshotOn();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormViewModel>(
      builder: (_, model, child) {
        if (model.isLoading) {
          return child ?? const SizedBox();
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              color: HexColor(AppState.instance.themeModel.backgroundColor),
              child: formViewModel.currentForm.formKey.isNotEmpty
                  ? Container(
                      color: Colors.white,
                      //HexColor(AppState.instance.themeModel.primaryColor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: FormFragmentWidget(
                              viewModel: formViewModel,
                              center: true,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null /*
                : Center(
                    child: Text(
                      constants.noFormsErrorMessage,
                      style: constants.normalGreyTextStyle,
                    ),
                  ),*/
              ),
        );
      },
      child: PopScope(
        canPop: !formViewModel.isLoading,
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
