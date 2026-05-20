import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/providers/appwrite_storage_providers.dart';
import 'package:skill_circle_app/features/posts/presentation/providers/posts_providers.dart';
import 'package:skill_circle_app/features/skill_circles/data/repositories/appwrite_skill_circle_repository.dart';
import 'package:skill_circle_app/features/skill_circles/domain/repositories/skill_circle_repository.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/controllers/create_circle_controller.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/controllers/skill_circles_controller.dart';

final skillCircleRepositoryProvider = Provider<SkillCircleRepository>((ref) {
  return AppwriteSkillCircleRepository(
    ref.read(appwriteDatabasesProvider),
    ref.read(appwriteRealtimeProvider),
    ref.read(appwriteAccountProvider),
    ref.read(appwriteStorageConfigProvider),
  );
});

final skillCirclesControllerProvider = StateNotifierProvider<SkillCirclesController, SkillCirclesState>((ref) {
  final repo = ref.watch(skillCircleRepositoryProvider);
  return SkillCirclesController(repo);
});

final createCircleControllerProvider = StateNotifierProvider.autoDispose<CreateCircleController, AsyncValue<void>>((ref) {
  final repo = ref.watch(skillCircleRepositoryProvider);
  final storage = ref.watch(storageServiceProvider);
  final ownerId = ref.watch(currentUserProvider)?.id ?? '';
  return CreateCircleController(repo, storage, ownerId);
});

final joinedCirclesStreamProvider = StreamProvider.family((ref, String userId) {
  final repo = ref.watch(skillCircleRepositoryProvider);
  return repo.watchJoinedCircles(userId);
});

final allCirclesStreamProvider = StreamProvider((ref) {
  final repo = ref.watch(skillCircleRepositoryProvider);
  return repo.watchSkillCircles();
});
