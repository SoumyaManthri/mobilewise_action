import 'flavor_config.dart';
import 'main_common.dart';
import 'utils/app_state.dart';
import 'utils/common_constants.dart' as constants;

void main() {
  final prodConfig = FlavorConfig(
      appName: constants.appNameProd,
  );
  AppState.instance.environment = constants.flavorNameProd;
  mainCommon(prodConfig);
}