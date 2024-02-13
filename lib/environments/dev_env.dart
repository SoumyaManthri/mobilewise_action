import 'package:envied/envied.dart';

part 'dev_env.g.dart';

@Envied(path: '.env.dev')
abstract class DevEnv {
  @EnviedField(varName: 'baseUrl', obfuscate: true)
  static final String baseUrl = _DevEnv.baseUrl;
  @EnviedField(varName: 'authBaseUrl', obfuscate: true)
  static final String authBaseUrl = _DevEnv.authBaseUrl;
  @EnviedField(varName: 'accessKey', obfuscate: true)
  static final String accessKey = _DevEnv.accessKey;
  @EnviedField(varName: 'secretKey', obfuscate: true)
  static final String secretKey = _DevEnv.secretKey;
  @EnviedField(varName: 'bucket', obfuscate: true)
  static final String bucket = _DevEnv.bucket;
  @EnviedField(varName: 'region', obfuscate: true)
  static final String region = _DevEnv.region;
}