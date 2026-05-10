import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/constants/appwrite_storage_config.dart';

final appwriteStorageConfigProvider = Provider<AppwriteStorageConfig>((ref) {
  return AppwriteStorageConfig.fromEnv();
});

final appwriteClientProvider = Provider<Client>((ref) {
  final config = ref.read(appwriteStorageConfigProvider);
  return Client()
      .setEndpoint(config.endpoint)
      .setProject(config.projectId);
});

final appwriteStorageProvider = Provider<Storage>((ref) {
  final client = ref.read(appwriteClientProvider);
  return Storage(client);
});