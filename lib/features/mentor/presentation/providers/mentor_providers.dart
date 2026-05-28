import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/providers/appwrite_storage_providers.dart';
import 'package:skill_circle_app/core/services/app_router.dart';
import 'package:skill_circle_app/features/mentor/data/appwrite_mentor_repository.dart';
import 'package:skill_circle_app/features/mentor/domain/entities/mentor.dart';
import 'package:skill_circle_app/features/mentor/domain/repositories/mentor_repository.dart';

final mentorRepositoryProvider = Provider<MentorRepository>((ref) {
  return AppwriteMentorRepository(
    ref.read(appwriteDatabasesProvider),
    ref.read(appwriteRealtimeProvider),
    ref.read(appwriteStorageConfigProvider),
  );
});

final currentMentorProfileProvider = FutureProvider.autoDispose<Mentor?>((ref) async {
  final user = ref.watch(routerAuthStateProvider).valueOrNull;
  if (user == null) return null;
  final repo = ref.read(mentorRepositoryProvider);
  final mentor = await repo.getMentorByUserId(user.id);
  return mentor;
});
