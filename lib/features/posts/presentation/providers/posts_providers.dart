import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/providers/appwrite_storage_providers.dart';
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:skill_circle_app/features/auth/domain/entities/app_user.dart';
import 'package:skill_circle_app/features/posts/data/repositories/appwrite_post_repository.dart';
import 'package:skill_circle_app/features/posts/domain/repositories/post_repository.dart';
import 'package:skill_circle_app/features/storage/data/appwrite_storage_service.dart';
import 'package:skill_circle_app/features/storage/domain/storage_service.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return AppwritePostRepository(
    ref.read(appwriteDatabasesProvider),
    ref.read(appwriteRealtimeProvider),
    ref.read(appwriteStorageConfigProvider),
  );
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final config = ref.read(appwriteStorageConfigProvider);
  final storage = ref.read(appwriteStorageProvider);
  return AppwriteStorageService(
    storage: storage,
    bucketId: config.bucketId,
    endpoint: config.endpoint,
    projectId: config.projectId,
  );
});

final currentUserProvider = Provider<AppUser?>((ref) => ref.watch(routerAuthStateProvider).valueOrNull);
