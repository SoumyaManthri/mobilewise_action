import 'package:flutter_mobilewise/screens/forgot_password/repository/forgot_password_repo.dart';
import 'package:get_it/get_it.dart';

import 'screens/change_password/repository/change_password_repo.dart';
import 'screens/forms/repository/form_repo.dart';
import 'screens/home/repository/home_repo.dart';
import 'screens/login/repository/login_repo.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerFactory<LoginRepository>(() => LoginRepositoryImpl());
  locator.registerFactory<HomeRepository>(() => HomeRepositoryImpl());
  locator.registerFactory<FormRepository>(() => FormRepositoryImpl());
  locator.registerFactory<ChangePasswordRepository>(() => ChangePasswordRepositoryImpl());
  locator.registerFactory<ForgotPasswordRepository>(() => ForgotPasswordRepositoryImpl());
}
