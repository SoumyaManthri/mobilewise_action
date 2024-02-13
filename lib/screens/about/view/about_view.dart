import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../screens/about/view_model/about_view_model.dart';
import '../../../utils/common_constants.dart' as constants;

class AboutScreenWidget extends StatefulWidget {
  const AboutScreenWidget({Key? key}) : super(key: key);

  @override
  State<AboutScreenWidget> createState() => _AboutScreenWidgetState();
}

class _AboutScreenWidgetState extends State<AboutScreenWidget> {
  late AboutViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<AboutViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        elevation: constants.appBarElevation,
        backgroundColor: const Color(constants.primaryColor),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(constants.mediumPadding),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    0.0, constants.largePadding * 0.8, 0.0, 0.0),
                child: Text(
                  constants.about,
                  style: constants.resetPasswordHeadingTextStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    0.0, constants.largePadding * 0.8, 0.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      constants.appVersionLabel,
                      style: constants.normalBoldBlackTextStyle,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, constants.smallPadding, 0.0, 0.0),
                      child: FutureBuilder<String>(
                        future: viewModel.getVersion(),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data.toString(),
                              style: constants.mediumBlackTextStyle,
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
