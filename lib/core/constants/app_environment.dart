enum AppEnvironment {
  dev,
  prod;

  static AppEnvironment fromName(String value) {
    switch (value.trim().toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'dev':
      case 'development':
      default:
        return AppEnvironment.dev;
    }
  }

  String get assetFilePath {
    switch (this) {
      case AppEnvironment.dev:
        return 'assets/env/.env.dev';
      case AppEnvironment.prod:
        return 'assets/env/.env.prod';
    }
  }
}