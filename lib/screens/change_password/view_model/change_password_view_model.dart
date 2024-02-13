import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../shared/model/common_api_response.dart';
import '../../../shared/view_model/loading_view_model.dart';
import '../repository/change_password_repo.dart';
import '../../../utils/common_constants.dart' as constants;

class ChangePasswordViewModel extends LoadingViewModel {
  ChangePasswordViewModel({
    required this.repo,
  });

  ChangePasswordRepository repo;

  Future<bool> changePassword(
      String newPassword, String confirmPassword, BuildContext context) async {
    if (newPassword != confirmPassword) {
      String message = constants.confirmPasswordError;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return false;
    }

    isLoading = true;
    CommonApiResponse response =
        await repo.changePassword(newPassword, context);
    isLoading = false;

    if (response != null) {
      String message = response.message ?? constants.passwordChangeMessage;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

      return response.statusCode == 200 ? true : false;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(constants.noNetworkAvailability)));
    }
    return false;
  }
}
