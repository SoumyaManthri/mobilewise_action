import 'flavor_config.dart';
import 'main_common.dart';
import 'utils/app_state.dart';
import 'utils/common_constants.dart' as constants;

void main() {
  final qaConfig = FlavorConfig(
    appName: constants.appNameQa,
  );
  AppState.instance.environment = constants.flavorNameQa;
  mainCommon(qaConfig);
}