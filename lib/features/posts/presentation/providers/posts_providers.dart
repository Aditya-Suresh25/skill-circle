import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skill_circle_app/features/posts/data/repositories/firebase_post_repository.dart';
import 'package:skill_circle_app/features/posts/domain/repositories/post_repository.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:skill_circle_app/features/storage/data/firebase_storage_service.dart';
import 'package:skill_circle_app/features/storage/domain/storage_service.dart';

final firebaseFirestoreProvider = Provider((ref) => FirebaseFirestore.instance);

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final firestore = ref.read(firebaseFirestoreProvider);
  return FirebasePostRepository(firestore);
});

final firebaseStorageInstanceProvider = Provider((ref) => fb.FirebaseStorage.instance);

final storageServiceProvider = Provider<StorageService>((ref) {
  final storage = ref.read(firebaseStorageInstanceProvider);
  return FirebaseStorageService(storage);
});

final currentUserProvider = Provider<User?>((ref) => FirebaseAuth.instance.currentUser);
