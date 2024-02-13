import 'package:flutter/material.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/hex_color.dart';
import '../../view_model/form_view_model.dart';

/// This widget is used to render the Hamburger menu for the home screen.
/// 1. homeButtons is used to render part of the menu dynamically based on
/// the resources assigned to this user.
/// 2. The other menu items like 'Settings', 'Help', 'About', 'Legal' and
/// 'Logout' are defined statically.
class AppDrawerWidget extends StatefulWidget {
  const AppDrawerWidget(
      {Key? key, required this.menuList, required this.viewModel})
      : super(key: key);

  final List<FrameworkFormField> menuList;
  final FormViewModel viewModel;

  @override
  State<AppDrawerWidget> createState() => _AppDrawerWidgetState();
}

class _AppDrawerWidgetState extends State<AppDrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
          color: HexColor(AppState.instance.themeModel.backgroundColor),
          child:ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: constants.appDrawerHeaderHeight,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: HexColor(AppState.instance.themeModel.primaryColor),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0,
                      constants.mediumPadding, constants.largePadding * 0.25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: constants.mediumPadding,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              'Hello, ${AppState.instance.username}',
                              style: constants.applyAppBarHeaderTextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          /// TODO - Uncomment when user profile can be edited from mobile app
                          /*Padding(
                            padding: const EdgeInsets.fromLTRB(
                                0.0, 0.0, 0.0, constants.xSmallPadding),
                            child: Container(
                              width: constants.appBarHeaderIconDimension,
                              height: constants.appBarHeaderIconDimension,
                              alignment: Alignment.bottomRight,
                              child: const Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),*/
                        ],
                      ),
                      const SizedBox(
                        height: constants.xSmallPadding,
                      ),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Expanded(
                      //       child: Text(
                      //         AppState.instance.userId,
                      //         style: constants.smallGreyTextStyle,
                      //         overflow: TextOverflow.ellipsis,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          widget.menuList.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _getListFromHomeContent(),
                )
              : const SizedBox(),
          widget.menuList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0.0, constants.smallPadding, 0.0, constants.smallPadding),
                  child: Container(
                    height: 1.0,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black,
                  ),
                )
              : const SizedBox(),
          /*ListTile(
            title: Text(
              constants.about,
              style: constants.appBarListTileTextStyle,
            ),
            onTap: () {
              /// Closing the app drawer, and navigating to About screen
              Future.delayed(const Duration(milliseconds: 100), () {
                widget.viewModel.navigateToAboutScreen(context);
              });
            },
          ),
          ListTile(
            title: Text(
              constants.changePassword,
              style: constants.appBarListTileTextStyle,
            ),
            onTap: () async {
              /// Calling logout in home view model
              Future.delayed(const Duration(milliseconds: 100), () {
                widget.viewModel.navigateToChangePasswordScreen(context);
              });
            },
          ),
          ListTile(
            title: Text(
              constants.logout,
              style: constants.appBarListTileTextStyle,
            ),
            onTap: () async {
              /// Calling logout in home view model
              Future.delayed(const Duration(milliseconds: 100), () {
                widget.viewModel.logOut(context);
              });
            },
          ),*/
        ],
      )),
    );
  }

  /// Creating a list of ListTiles to populate the dynamic part of the menu
  _getListFromHomeContent() {
    List<Widget> widgets = <Widget>[];
    for (FrameworkFormField menu in widget.menuList) {
      widgets.add(ListTile(
        title: Text(
          menu.label,
          style: constants.applyStyleV2(color: AppState.instance.themeModel.textColor),
        ),
        onTap: () {
          _onPressed(menu);
          /*  /// Close app drawer and navigate to form
          Future.delayed(const Duration(milliseconds: 100), () {
            widget.viewModel.navigateToFormScreen(context, menu);
          });*/
        },
      ));
    }
    return widgets;
  }

  _onPressed(FrameworkFormField menu) {
    if (widget.viewModel.scaffoldKey.currentState!.isDrawerOpen!) {
      widget.viewModel.scaffoldKey.currentState?.openEndDrawer();
    }

    widget.viewModel.fieldButtonPressed(menu, context, false, '');
  }
}
