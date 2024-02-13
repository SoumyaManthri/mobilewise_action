import 'package:envied/envied.dart';

part 'qa_env.g.dart';

@Envied(path: '.env.qa')
abstract class QaEnv {
  @EnviedField(varName: 'baseUrl', obfuscate: true)
  static final String baseUrl = _QaEnv.baseUrl;
  @EnviedField(varName: 'authBaseUrl', obfuscate: true)
  static final String authBaseUrl = _QaEnv.authBaseUrl;
  @EnviedField(varName: 'accessKey', obfuscate: true)
  static final String accessKey = _QaEnv.accessKey;
  @EnviedField(varName: 'secretKey', obfuscate: true)
  static final String secretKey = _QaEnv.secretKey;
  @EnviedField(varName: 'bucket', obfuscate: true)
  static final String bucket = _QaEnv.bucket;
  @EnviedField(varName: 'region', obfuscate: true)
  static final String region = _QaEnv.region;
}