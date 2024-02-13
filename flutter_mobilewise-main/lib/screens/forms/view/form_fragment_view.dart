import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../screens/forms/view_model/form_view_model.dart';
import '../../../shared/model/framework_form.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/hex_color.dart';

/// Fragment to show the current subform from the list of forms.
/// Renders the form fields and buttons.
/// Also detects if the formType is 'PREVIEW' and renders the view accordingly.
class FormFragmentWidget extends StatefulWidget {
  const FormFragmentWidget(
      {Key? key, required this.viewModel, this.center = false})
      : super(key: key);

  final FormViewModel viewModel;
  final bool center;

  @override
  State<FormFragmentWidget> createState() => _FormFragmentWidgetState();
}

class _FormFragmentWidgetState extends State<FormFragmentWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.setScrollController(_scrollController);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormViewModel>(builder: (_, model, child) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: widget.center
                  ? Center(
                      child: body(),
                    ):
                     body()
          ),
          widget.viewModel.currentForm.buttons.isNotEmpty
              ? Container(
                  height: constants.horizontalSeparatorHeight,
                  color: Colors.black,
                )
              : const SizedBox(),
          widget.viewModel.currentForm.buttons.isNotEmpty

              /// Removed the extra padding of form button in bottom for the android
              ? Platform.isIOS
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(
                          0.0, 0.0, 0.0, constants.mediumPadding),
                      child: SizedBox(
                        /*width: MediaQuery.of(context).size.width,*/
                        height: constants.formButtonBarHeight,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _getFormButtons(context),
                        ),
                      ),
                    )
                  : SizedBox(
                      /*width: MediaQuery.of(context).size.width,*/
                      height: constants.formButtonBarHeight,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _getFormButtons(context),
                      ),
                    )
              : const SizedBox(),
        ],
      );
    });
  }

  /// Horizontal row to show buttons on the bottom of the form
  _getFormButtons(BuildContext context) {
    List<Widget> buttons = <Widget>[];
    for (FrameworkFormButton button in widget.viewModel.currentForm.buttons) {
      buttons.add(
        button.type == 2 && widget.viewModel.isLoading
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0,
                      constants.largePadding, 0.0, constants.mediumPadding),
                  child: CircularProgressIndicator(
                    color: HexColor(AppState.instance.themeModel.primaryColor),
                  ),
                ),
              )
            : Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(constants.mediumPadding),
                  child: SizedBox(
                    height: constants.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Form button clicked
                        widget.viewModel.buttonPressed(button.key, context);
                      },
                      style: constants.buttonStyle(
                          backgroundColor: HexColor(
                              AppState.instance.themeModel.primaryColor)),
                      child: Text(
                        button.label,
                        style: constants.buttonTextStyle,
                      ),
                    ),
                  ),
                ),
              ),
      );
    }
    if (buttons.isEmpty) {
      buttons.add(const SizedBox());
    }
    return buttons;
  }

  body() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: SizedBox(
        /*width: MediaQuery.of(context).size.width,*/
        child: Padding(
          padding: const EdgeInsets.all(constants.mediumPadding),
          child: Column(
            children: widget.viewModel.getFormFields(),
          ),
        ),
      ),
    );
  }
}
