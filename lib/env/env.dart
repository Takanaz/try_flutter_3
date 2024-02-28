import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'PIXABAY_API_KEY', obfuscate: true)
  static String pixabayApiKey = _Env.pixabayApiKey;
}
