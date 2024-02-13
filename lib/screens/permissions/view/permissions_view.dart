import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../screens/permissions/view_model/permissions_view_model.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/hex_color.dart';

class PermissionsScreenWidget extends StatefulWidget {
  const PermissionsScreenWidget({Key? key}) : super(key: key);

  @override
  State<PermissionsScreenWidget> createState() =>
      _PermissionsScreenWidgetState();
}

class _PermissionsScreenWidgetState extends State<PermissionsScreenWidget> {
  late PermissionsViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<PermissionsViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: HexColor(AppState.instance.themeModel.backgroundColor),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: constants.permissionScreenTopBarHeight,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          constants.largePadding,
                          constants.largePadding * 2,
                          constants.largePadding,
                          constants.largePadding),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                0.0, 0.0, constants.mediumPadding, 0.0),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: HexColor(
                                  AppState.instance.themeModel.primaryColor),
                              size: constants.permissionIconDimension,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 0.0, 0.0, constants.smallPadding),
                                  child: Text(
                                    constants.locationPermissionHeading,
                                    style: constants.normalTextStyle,
                                  ),
                                ),
                                Text(
                                  constants.locationPermissionSubHeading,
                                  style: constants.mediumTextStyle,
                                  maxLines: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        constants.largePadding,
                        0.0,
                        constants.largePadding,
                        constants.largePadding,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                0.0, 0.0, constants.mediumPadding, 0.0),
                            child: Icon(
                              Icons.camera_alt,
                              color: HexColor(
                                  AppState.instance.themeModel.primaryColor),
                              size: constants.permissionIconDimension,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 0.0, 0.0, constants.smallPadding),
                                  child: Text(
                                    constants.cameraPermissionHeading,
                                    style: constants.normalTextStyle,
                                  ),
                                ),
                                Text(
                                  constants.cameraPermissionSubHeading,
                                  style: constants.mediumTextStyle,
                                  maxLines: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  0.0, 0.0, 0.0, constants.mediumPadding),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: constants.formButtonBarHeight,
                child: Padding(
                  padding: const EdgeInsets.all(constants.mediumPadding),
                  child: SizedBox(
                    height: constants.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        viewModel.requestPermissionsAndNavigate(context);
                      },
                      style: constants.buttonStyle(
                          backgroundColor: HexColor(
                              AppState.instance.themeModel.primaryColor)),
                      child: Text(
                        constants.allowPermissions,
                        style: constants.buttonTextStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
