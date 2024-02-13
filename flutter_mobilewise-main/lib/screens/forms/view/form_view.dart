import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../screens/forms/view_model/form_view_model.dart';
import '../../../shared/model/form_arguments.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/hex_color.dart';
import '../../../utils/navigation_util.dart';
import '../../../utils/util.dart';
import 'form_field_v2/app_drawer_form_view.dart';
import 'form_fragment_view.dart';

/// Form screen (activity) within which form fragment widgets are going to be
/// rendered from the list of sub-forms
class FormScreenWidget extends StatefulWidget {
  const FormScreenWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<FormScreenWidget> createState() => _FormScreenWidgetState();
}

class _FormScreenWidgetState extends State<FormScreenWidget> {
  late FormViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<FormViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (viewModel.currentForm.formKey.isEmpty) {
      final args = ModalRoute.of(context)!.settings.arguments as FormArguments;
      viewModel.formId = args.formId;
      viewModel.initializeForm();
      viewModel.findCurrentForm(viewModel.formsList.initialFormKey);
    }
    return Consumer<FormViewModel>(
      builder: (_, model, child) {
        return WillPopScope(
          onWillPop: () async {
            if (await NavigationUtil.instance
                .avoidBackPressWhenLoadingViewModel(viewModel.isLoading)) {
              viewModel.onBackPressed(context);
            }
            return false;
          },
          child: Listener(
            onPointerDown: (event) {
              FocusManager.instance.primaryFocus?.unfocus();

              /// Removes all the dropdown widgets if touched anywhere else on screen.
              Util.instance.removeAllDropDownOverlays();
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: viewModel.getAppBar(context),
              drawer: viewModel.currentForm.menuDrawer.isNotEmpty
                  ? AppDrawerWidget(
                      menuList: viewModel.currentForm.menuDrawer,
                      viewModel: viewModel,
                    )
                  : null,
              body: Container(
                color: HexColor(AppState.instance.themeModel.backgroundColor),
                child: SafeArea(
                  child: viewModel.currentForm.formKey.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: FormFragmentWidget(
                              viewModel: viewModel,
                            ))
                          ],
                        )
                      : Center(
                          child: Text(
                            constants.noFormsErrorMessage,
                            style: constants.normalGreyTextStyle,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
