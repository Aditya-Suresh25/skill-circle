import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skill_circle_app/core/providers/appwrite_storage_providers.dart';
import 'package:skill_circle_app/features/posts/data/repositories/firebase_post_repository.dart';
import 'package:skill_circle_app/features/posts/domain/repositories/post_repository.dart';
import 'package:skill_circle_app/features/storage/data/appwrite_storage_service.dart';
import 'package:skill_circle_app/features/storage/domain/storage_service.dart';

final firebaseFirestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final firestore = ref.read(firebaseFirestoreProvider);
  return FirebasePostRepository(firestore);
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

final currentUserProvider = Provider<User?>((ref) => FirebaseAuth.instance.currentUser);
