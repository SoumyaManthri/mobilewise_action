import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/util.dart';
import '../../model/submitted_data_model.dart';

class FormDataListWidget extends StatefulWidget {
  const FormDataListWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormDataListWidget> createState() => _FormDataListWidgetState();
}

class _FormDataListWidgetState extends State<FormDataListWidget> {
  List<String> lhsWidget = [];
  List<String> rhsWidget = [];

  @override
  void initState() {
    super.initState();
    if (widget.field.isEditable &&
        AppState.instance.formTempMap.containsKey(widget.field.key)) {
    } else if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.field.key)) {}

    List lhs = (json.decode(widget.field.values[0].value));
    for (var widget in lhs) {
      lhsWidget.add(widget['widgetId']);
    }

    List rhs = (json.decode(widget.field.values[1].value));
    for (var widget in rhs) {
      rhsWidget.add(widget['widgetId']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future:
          widget.viewModel.fetchDataListData(widget.field.entityId, context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // If the API call was successful, build the ListView
          return Padding(
              padding: EdgeInsets.only(
                  top: Util.instance.getTopMargin(widget.field.style),
                  bottom: 50),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 100,
                child: _view(snapshot.data as List<Submissions>),
              ));
        } else if (snapshot.hasError) {
          // If the API call was unsuccessful, display an error message
          return Center(
            child: Text('${snapshot.error}'),
          );
        }

        // If the data is still being loaded, show a loading indicator
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: constants.getIndicator(),
        );
      },
    );
  }

  _view(List<Submissions> data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _cardView(data[index]);
        });
  }

  List<Widget> getLeftView(Map<String, EntityValuesJson> dataMap) {
    List values = lhsWidget;

    List<Widget> widgets = [];
    for (int i = 0; i < values.length; i++) {
      widgets.add(Align(
          alignment: Alignment.centerLeft, child: getText(dataMap, values[i])));
    }
    return widgets;
  }

  List<Widget> getRightView(Map<String, EntityValuesJson> dataMap) {
    List values = rhsWidget;

    List<Widget> widgets = [];
    for (int i = 0; i < values.length; i++) {
      widgets.add(Align(
          alignment: Alignment.centerRight,
          child: getText(dataMap, values[i], textAlign: TextAlign.right)));
    }
    return widgets;
  }

  getText(Map<String, EntityValuesJson> dataMap, String value,
      {TextAlign textAlign = TextAlign.left}) {
    return Padding(
        padding:
            const EdgeInsets.symmetric(vertical: constants.xxSmallSpaceHeight),
        child: Text(
          dataMap[value.trim()]?.value ?? "-",
          textAlign: textAlign,
          style: const TextStyle(fontSize: 16),
        ));
  }

  _cardView(Submissions data) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(constants.smallPadding),
            child: ListTile(
                onTap: () => onClick(data),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.only(right: constants.smallPadding),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Column(
                                    children: getLeftView(data.dataMap!))))),
                    Expanded(
                        flex: 1,
                        child: Padding(
                            padding: const EdgeInsets.only(left: constants.smallPadding),
                            child: Align(
                                alignment: Alignment.topRight,
                                child: Column(
                                    children: getRightView(data.dataMap!))))),
                  ],
                ))));
  }

  onClick(Submissions data) {
    widget.viewModel.dataListSelected = data;
    widget.viewModel.nextButtonPressed(widget.field.decisionNode, context);
  }
}
