import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteStorageConfig {
  const AppwriteStorageConfig({
    required this.endpoint,
    required this.projectId,
    required this.bucketId,
    required this.databaseId,
    required this.usersCollectionId,
    required this.skillCirclesCollectionId,
    required this.postsCollectionId,
    required this.commentsCollectionId,
    required this.channelsCollectionId,
    required this.messagesCollectionId,
  });

  final String endpoint;
  final String projectId;
  final String bucketId;
  final String databaseId;
  final String usersCollectionId;
  final String skillCirclesCollectionId;
  final String postsCollectionId;
  final String commentsCollectionId;
  final String channelsCollectionId;
  final String messagesCollectionId;

  static AppwriteStorageConfig fromEnv() {
    return AppwriteStorageConfig(
      endpoint: _required('APPWRITE_ENDPOINT'),
      projectId: _required('APPWRITE_PROJECT_ID'),
      bucketId: _required('APPWRITE_STORAGE_BUCKET_ID'),
      databaseId: _required('APPWRITE_DATABASE_ID'),
      usersCollectionId: _required('APPWRITE_USERS_COLLECTION_ID'),
      skillCirclesCollectionId: _required('APPWRITE_SKILL_CIRCLES_COLLECTION_ID'),
      postsCollectionId: _required('APPWRITE_POSTS_COLLECTION_ID'),
      commentsCollectionId: _required('APPWRITE_COMMENTS_COLLECTION_ID'),
      channelsCollectionId: _required('APPWRITE_CHANNELS_COLLECTION_ID'),
      messagesCollectionId: _required('APPWRITE_MESSAGES_COLLECTION_ID'),
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