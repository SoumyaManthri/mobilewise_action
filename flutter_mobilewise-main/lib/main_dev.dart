import 'flavor_config.dart';
import 'main_common.dart';
import 'utils/app_state.dart';
import 'utils/common_constants.dart' as constants;

void main() {
  final devConfig = FlavorConfig(
      appName: constants.appNameDev,
  );
  AppState.instance.environment = constants.flavorNameDev;
  mainCommon(devConfig);
}