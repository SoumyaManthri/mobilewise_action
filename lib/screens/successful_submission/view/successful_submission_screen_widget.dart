import 'dart:async';

import 'package:flutter/material.dart';

import '../../../screens/successful_submission/model/successful_submission_arguments.dart';
import '../../../shared/event/app_events.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/hex_color.dart';

class SuccessfulSubmissionScreenWidget extends StatefulWidget {
  const SuccessfulSubmissionScreenWidget({Key? key}) : super(key: key);

  @override
  State<SuccessfulSubmissionScreenWidget> createState() =>
      _SuccessfulSubmissionScreenWidgetState();
}

class _SuccessfulSubmissionScreenWidgetState
    extends State<SuccessfulSubmissionScreenWidget> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as SuccessfulSubmissionArguments;
    return WillPopScope(
      onWillPop: () async {
        _finish(args.message);
        return false;
      },
      child: Scaffold(
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
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Image(
                          image: AssetImage(constants.greenTick),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              0.0, constants.largePadding, 0.0, 0.0),
                          child: Text(
                            args.message,
                            style: constants.resetPasswordHeadingTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0.0, 0.0, 0.0, constants.mediumPadding * 1.25),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: constants.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        _finish(args.message);
                      },
                      style: constants.buttonStyle(
                          backgroundColor: HexColor(
                              AppState.instance.themeModel.primaryColor)),
                      child: Text(
                        constants.finish,
                        style: constants.buttonTextStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _finish(String message) {
    Navigator.pop(context);
    Navigator.pop(context);
    if (message == constants.success) {
      /// This is an online submission
      /// With a delay of 500 ms, start app sync
      Timer(
          const Duration(
              milliseconds: constants.postSubmissionSyncDelayDuration), () {
        AppState.instance.eventBus.fire(SuccessfulProjectSubmissionEvent());
      });
    } else {
      /// To refresh the Offline submission count.
      AppState.instance.eventBus.fire(RefreshSyncCount());
    }
  }
}
