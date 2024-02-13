import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../shared/model/common_api_response.dart';
import '../../../shared/view_model/loading_view_model.dart';
import '../repository/forgot_password_repo.dart';
import '../../../utils/common_constants.dart' as constants;

class ForgotPasswordViewModel extends LoadingViewModel {
  ForgotPasswordViewModel({
    required this.repo,
  });

  ForgotPasswordRepository repo;

  Future<bool> forgotPassword(String username, BuildContext context) async {
    isLoading = true;
    CommonApiResponse response =
        await repo.forgotPassword(username, context);
    isLoading = false;

    if (response != null) {
      String message = response.message ?? constants.passwordResetMessage;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

      return response.message == null ? true : false;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(constants.noNetworkAvailability)));
    }
    return false;
  }
}
