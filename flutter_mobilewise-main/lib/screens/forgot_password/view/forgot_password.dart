import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/common_constants.dart' as constants;
import '../../../utils/app_state.dart';
import '../../../utils/hex_color.dart';
import '../view_model/forgot_password_view_model.dart';

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordWidget> createState() =>
      _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  late ForgotPasswordViewModel viewModel;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    viewModel = Provider.of<ForgotPasswordViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgotPasswordViewModel>(builder: (_, model, child) {
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
                    child: null),
                _usernameField(
                    label: constants.userName,
                    controller: _usernameController),
                _forgotPasswordBtnWithProgress()
              ],
            ))));
  }

  _usernameField(
      {required String label,
      TextEditingController? controller}) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, constants.mediumPadding),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        enableSuggestions: true,
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
      iconTheme: IconThemeData(
        color: HexColor(AppState.instance.themeModel.secondaryColor),
      ),
      elevation: constants.appBarElevation,
      backgroundColor: HexColor(AppState.instance.themeModel.primaryColor),
      title:  Text(constants.resetPasswordHeading,
        style: TextStyle(
          color: HexColor(AppState.instance.themeModel.secondaryColor)
        ),
      ),
    );
  }

  _forgotPasswordBtnWithProgress() {
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
                        String username = _usernameController.text;

                        bool isSuccess = await viewModel.forgotPassword(
                            username, context);

                        if (isSuccess) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: constants.buttonStyle(backgroundColor: HexColor(AppState.instance.themeModel.primaryColor)),
                    child: Text(
                      constants.reset,
                      style: TextStyle(
                        fontSize: 18,
                        color: HexColor(AppState.instance.themeModel.secondaryColor),
                        fontWeight: FontWeight.w500,
                      ),
                    ))));
  }
}
