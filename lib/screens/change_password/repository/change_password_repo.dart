import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/services/api_provider.dart';
import '../../../shared/model/common_api_response.dart';

/// Abstract class for the change password repository
abstract class ChangePasswordRepository {
  Future<CommonApiResponse> logout(String token);

  Future<CommonApiResponse> changePassword(
      String newPassword, BuildContext context);
}

class ChangePasswordRepositoryImpl extends ChangePasswordRepository {
  @override
  Future<CommonApiResponse> changePassword(
      String newPassword, BuildContext context) async {

    Future<CommonApiResponse> response = ApiProvider().changePassword(newPassword);

    return response;
  }

  @override
  Future<CommonApiResponse> logout(String token) {
    // TODO: implement logout
    throw UnimplementedError();
  }
}
