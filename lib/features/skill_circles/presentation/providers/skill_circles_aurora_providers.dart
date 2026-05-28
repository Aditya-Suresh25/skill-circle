import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/providers/appwrite_storage_providers.dart';
import 'package:skill_circle_app/features/skill_circles/data/repositories/appwrite_skill_circle_repository.dart';
import 'package:skill_circle_app/features/skill_circles/domain/repositories/skill_circle_repository.dart';
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

final allCirclesStreamProvider = StreamProvider((ref) {
  final repo = ref.watch(skillCircleRepositoryProvider);
  return repo.watchSkillCircles();
});
