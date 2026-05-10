import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteStorageConfig {
  const AppwriteStorageConfig({
    required this.endpoint,
    required this.projectId,
    required this.bucketId,
  });

  final String endpoint;
  final String projectId;
  final String bucketId;

  static AppwriteStorageConfig fromEnv() {
    return AppwriteStorageConfig(
      endpoint: _required('APPWRITE_ENDPOINT'),
      projectId: _required('APPWRITE_PROJECT_ID'),
      bucketId: _required('APPWRITE_STORAGE_BUCKET_ID'),
    );
  }

  static String _required(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty || value == 'replace_me') {
      throw StateError('$key is missing from the current environment file');
    }
    return value;
  }
}