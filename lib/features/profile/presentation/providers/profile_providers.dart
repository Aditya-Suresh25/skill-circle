import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/profile/data/repositories/firebase_profile_repository.dart';
import 'package:skill_circle_app/features/profile/domain/entities/profile.dart';
import 'package:skill_circle_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:skill_circle_app/features/profile/presentation/controllers/profile_controller.dart';

/// Provider for Firebase instances
final _firebaseFirestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final _firebaseStorageProvider =
    Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

/// Provider for ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final firestore = ref.watch(_firebaseFirestoreProvider);
  final storage = ref.watch(_firebaseStorageProvider);
  return FirebaseProfileRepository(firestore, storage);
});

/// StateNotifierProvider for profile operations and state
final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<Profile?>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileController(repository);
});

/// Stream provider for watching profile changes in real-time
final profileStreamProvider = StreamProvider.family<Profile?, String>((
  ref,
  userId,
) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.watchProfile(userId);
});
