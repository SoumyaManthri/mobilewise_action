import 'package:flutter/material.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/util.dart';

class FormTimePreviewFieldWidget extends StatefulWidget {
  const FormTimePreviewFieldWidget({
    Key? key,
    required this.field,
    required this.fieldKey,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final String fieldKey;
  final FormViewModel viewModel;

  @override
  State<FormTimePreviewFieldWidget> createState() =>
      _FormTimePreviewFieldWidgetState();
}

class _FormTimePreviewFieldWidgetState
    extends State<FormTimePreviewFieldWidget> {
  String initValue = '';

  @override
  Widget build(BuildContext context) {
    /// Initializing value
    _initValue();

    return initValue.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.fromLTRB(
                constants.mediumPadding,
                constants.smallPadding,
                constants.mediumPadding,
                constants.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.field.label,
                  style: constants.smallGreyTextStyle,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0.0, constants.smallPadding, 0.0, constants.smallPadding),
                  child: Text(
                    Util.instance.getLocalDate(initValue),
                    style: constants.normalBlackTextStyle,
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  /// This method is called to initialize edittext value
  _initValue() {
    if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.fieldKey)) {
      initValue = widget.viewModel.clickedSubmissionValuesMap[widget.fieldKey];
    }
  }
}
