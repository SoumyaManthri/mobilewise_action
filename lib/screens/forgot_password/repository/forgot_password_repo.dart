import 'package:flutter/material.dart';

import '../../../services/api_provider.dart';
import '../../../shared/model/common_api_response.dart';

/// Abstract class for the Forgot password repository
abstract class ForgotPasswordRepository {

  Future<CommonApiResponse> forgotPassword(
      String username, BuildContext context);
}

class ForgotPasswordRepositoryImpl extends ForgotPasswordRepository {
  @override
  Future<CommonApiResponse> forgotPassword(
      String username, BuildContext context) async {

    Future<CommonApiResponse> response = ApiProvider().forgotPassword(username);

    return response;
  }
}
