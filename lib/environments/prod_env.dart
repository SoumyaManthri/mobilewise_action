import 'package:envied/envied.dart';

part 'prod_env.g.dart';

@Envied(path: '.env.prod')
abstract class ProdEnv {
  @EnviedField(varName: 'baseUrl', obfuscate: true)
  static final String baseUrl = _ProdEnv.baseUrl;
  @EnviedField(varName: 'authBaseUrl', obfuscate: true)
  static final String authBaseUrl = _ProdEnv.authBaseUrl;
  @EnviedField(varName: 'accessKey', obfuscate: true)
  static final String accessKey = _ProdEnv.accessKey;
  @EnviedField(varName: 'secretKey', obfuscate: true)
  static final String secretKey = _ProdEnv.secretKey;
  @EnviedField(varName: 'bucket', obfuscate: true)
  static final String bucket = _ProdEnv.bucket;
  @EnviedField(varName: 'region', obfuscate: true)
  static final String region = _ProdEnv.region;
}