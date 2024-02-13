import '../../../shared/view_model/loading_view_model.dart';
import '../../../utils/util.dart';

class AboutViewModel extends LoadingViewModel {
  Future<String> getVersion() async {
    return await Util.instance.getAppVersion();
  }
}
