import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/screens/change_password/view_model/change_password_view_model.dart';
import 'package:provider/provider.dart';

import '../../../../utils/common_constants.dart' as constants;
import '../../../utils/app_state.dart';
import '../../../utils/hex_color.dart';

class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({Key? key}) : super(key: key);

  @override
  State<ChangePasswordWidget> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  late ChangePasswordViewModel viewModel;

  final _formKey = GlobalKey<FormState>();
  late bool _passwordVisible;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    viewModel = Provider.of<ChangePasswordViewModel>(context, listen: false);
    _passwordVisible = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChangePasswordViewModel>(builder: (_, model, child) {
      return PopScope(
          canPop: !model.isLoading,
          child: Scaffold(
            appBar: _appBar(),
            resizeToAvoidBottomInset: true,
            body: _body(),
          ));
    });
  }

  _body() {
    return Form(
        key: _formKey,
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: HexColor(AppState.instance.themeModel.backgroundColor),
            padding: const EdgeInsets.all(constants.mediumPadding),
            child: SingleChildScrollView(
                child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                    padding: EdgeInsets.all(constants.largePadding * 3),
                    child: null
                ),
                _passwordField(
                    label: constants.newPassword,
                    controller: _newPasswordController),
                _passwordField(
                    label: constants.confirmPassword,
                    controller: _confirmPasswordController,
                    passwordVisibilityIcon: false),
                _changePasswordBtnWithProgress()
              ],
            ))));
  }

  _passwordField(
      {required String label,
      TextEditingController? controller,
      bool passwordVisibilityIcon = true}) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, constants.mediumPadding),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        obscureText: !_passwordVisible,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: constants.normalBlackTextStyle,
          fillColor: HexColor(AppState.instance.themeModel.backgroundColor),
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: 2,
                color: HexColor(AppState.instance.themeModel.primaryColor)),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
                width: 2,
                color: HexColor(AppState.instance.themeModel.primaryColor)),
          ),
          enabledBorder:
          const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.red)),
          floatingLabelStyle:
          TextStyle(color: HexColor(AppState.instance.themeModel.primaryColor)),
          errorStyle: const TextStyle(color: Colors.red),
          suffixIcon: !passwordVisibilityIcon
              ? null
              : IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label ${constants.emptyErrorMsg}';
          }
          return null;
        },
        onSaved: (value) {
          _formKey.currentState!.validate();
        },
      ),
    );
  }

  _appBar() {
    return AppBar(
      iconTheme:  IconThemeData(
        color: HexColor(AppState.instance.themeModel.secondaryColor),
      ),
      elevation: constants.appBarElevation,
      backgroundColor: HexColor(AppState.instance.themeModel.primaryColor),
      title:  Text(constants.changePassword,
      style: TextStyle(
        color: HexColor(AppState.instance.themeModel.secondaryColor)
      ),),
    );
  }

  _changePasswordBtnWithProgress() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(
            0.0, constants.largePadding, 0.0, constants.mediumPadding),
        child: viewModel.isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: constants.buttonHeight,
                child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String newPassword = _newPasswordController.text;
                        String confirmPassword =
                            _confirmPasswordController.text;

                        bool isSuccess = await viewModel.changePassword(
                            newPassword, confirmPassword, context);

                        if(isSuccess){
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: constants.buttonStyle(backgroundColor: HexColor(AppState.instance.themeModel.primaryColor)),
                    child: Text(
                      constants.changePassword,
                      style: TextStyle(
                        fontSize: 18,
                        color: HexColor(AppState.instance.themeModel.secondaryColor),
                        fontWeight: FontWeight.w500,
                      ),
                    ))));
  }
}
