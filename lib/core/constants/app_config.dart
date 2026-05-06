import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skill_circle_app/core/constants/app_environment.dart';

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.appName,
    required this.showDebugBanner,
    required this.enableLogging,
    required this.enableGoogleSignIn,
  });

  final AppEnvironment environment;
  final String appName;
  final bool showDebugBanner;
  final bool enableLogging;
  final bool enableGoogleSignIn;

  static Future<AppConfig> load() async {
    final environment = AppEnvironment.fromName(
      const String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
    );

    await dotenv.load(fileName: environment.assetFilePath);

    return AppConfig(
      environment: environment,
      appName: _readString('APP_NAME', fallback: 'Skill Circle'),
      showDebugBanner: _readBool('APP_SHOW_DEBUG_BANNER', fallback: false),
      enableLogging: _readBool('APP_ENABLE_LOGGING', fallback: true),
      enableGoogleSignIn: _readBool('APP_ENABLE_GOOGLE_SIGN_IN', fallback: false),
    );
  }

  static String _readString(String key, {required String fallback}) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value;
  }

  static bool _readBool(String key, {required bool fallback}) {
    final value = dotenv.env[key]?.trim().toLowerCase();
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value == 'true';
  }
}