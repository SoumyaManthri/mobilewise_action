import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/screens/forms/view/form_field_views/form_button_field_widget.dart';
import 'package:flutter_mobilewise/shared/model/form_preview_arguments.dart';
import 'package:flutter_mobilewise/utils/app_state.dart';
import 'package:flutter_mobilewise/utils/hex_color.dart';
import 'package:provider/provider.dart';

import '../../../screens/forms/view_model/form_view_model.dart';
import '../../../shared/model/framework_form.dart';
import '../../../utils/common_constants.dart' as constants;

/// Fragment to show the current subform from the list of forms.
/// Renders the form fields and buttons.
/// Also detects if the formType is 'PREVIEW' and renders the view accordingly.
class FormPreviewFragmentWidget extends StatefulWidget {
  const FormPreviewFragmentWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<FormPreviewFragmentWidget> createState() =>
      _FormPreviewFragmentWidgetState();
}

class _FormPreviewFragmentWidgetState extends State<FormPreviewFragmentWidget> {
  final ScrollController _scrollController = ScrollController();
  late FormViewModel formViewModel;
  late FrameworkFormField button;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    formViewModel = Provider.of<FormViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)!.settings.arguments as FormPreviewArguments;
      button = args.button;
      button = _cloneButton();

      setState(() {
        isLoading = false;
      });
    });
  }

  _cloneButton() {
    FrameworkFormFieldValuesFromApi valuesFromApi =
        FrameworkFormFieldValuesFromApi(
            url: button.valuesApi.url,
            type: button.valuesApi.type,
            params: button.valuesApi.params,
            headers: button.valuesApi.headers,
            responseParameter: button.valuesApi.responseParameter,
            requestKeys: button.valuesApi.requestKeys,
            values: button.valuesApi.values,
            isPreview: false);

    return FrameworkFormField(
        key: button.key,
        label: button.label,
        uiType: button.uiType,
        datatype: button.datatype,
        type: button.type,
        matUiType: button.matUiType,
        defaultValue: button.defaultValue,
        isMandatory: button.isMandatory,
        allowCustomEntry: button.allowCustomEntry,
        values: button.values,
        valuesApi: valuesFromApi,
        hint: button.hint,
        validations: button.validations,
        subform: button.subform,
        dataListItemSubform: button.dataListItemSubform,
        dataListClickSubform: button.dataListClickSubform,
        dataListFilterSubform: button.dataListFilterSubform,
        icon: button.icon,
        textSize: button.textSize,
        textStyle: button.textStyle,
        textColor: button.textColor,
        orientation: button.orientation,
        flex: button.flex,
        isEditable: button.isEditable,
        filterBy: button.filterBy,
        decisionNode: button.decisionNode,
        max: button.max,
        regex: button.regex,
        timelineHistoryKey: button.timelineHistoryKey,
        numericFieldChange: button.numericFieldChange,
        image: button.image,
        entityId: button.entityId,
        style: button.style);
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Scaffold(
            appBar: formViewModel.currentForm.navBar.isNotEmpty
                ? _getAppBar()
                : null,
            resizeToAvoidBottomInset: false,
            body: Container(
              color: HexColor(AppState.instance.themeModel.backgroundColor),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SafeArea(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Container(
                          color: HexColor(
                              AppState.instance.themeModel.backgroundColor),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: constants.mediumPadding,
                                horizontal: constants.smallPadding),
                            child: Column(
                              children: formViewModel
                                  .getPreviewFormFieldsBasedOnDecisionNodes(
                                      context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color:
                        HexColor(AppState.instance.themeModel.backgroundColor),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          constants.mediumPadding,
                          0.0,
                          constants.mediumPadding,
                          constants.mediumPadding),
                      child: SizedBox(
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        child: FormButtonFieldWidget(
                          key: Key(button.key),
                          viewModel: formViewModel,
                          field: button,
                          label: button.label,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: formViewModel.currentForm.navBar.isNotEmpty
                ? _getAppBar()
                : null,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: constants.getIndicator(),
              ),
            ),
          );
  }

  _getAppBar() {
    String text = '';

    for (var element in formViewModel.currentForm.navBar) {
      switch (element.uiType) {
        case constants.navText:
          text = "Preview";
          break;
      }
    }

    return formViewModel.getAppBar(context, title: text, iconList: [2]);
  }
}
