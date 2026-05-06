import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/skill_circles/data/repositories/firebase_skill_circle_repository.dart';
import 'package:skill_circle_app/features/skill_circles/domain/repositories/skill_circle_repository.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/controllers/create_circle_controller.dart';
import 'package:skill_circle_app/features/skill_circles/presentation/controllers/skill_circles_controller.dart';

final _firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final skillCircleRepositoryProvider = Provider<SkillCircleRepository>((ref) {
  final fs = ref.watch(_firestoreProvider);
  return FirebaseSkillCircleRepository(fs);
});

final skillCirclesControllerProvider = StateNotifierProvider<SkillCirclesController, SkillCirclesState>((ref) {
  final repo = ref.watch(skillCircleRepositoryProvider);
  return SkillCirclesController(repo);
});

final createCircleControllerProvider = StateNotifierProvider.autoDispose<CreateCircleController, AsyncValue<void>>((ref) {
  final repo = ref.watch(skillCircleRepositoryProvider);
  return CreateCircleController(repo);
});

final joinedCirclesStreamProvider = StreamProvider.family((ref, String userId) {
  final repo = ref.watch(skillCircleRepositoryProvider);
  return repo.watchJoinedCircles(userId);
});
