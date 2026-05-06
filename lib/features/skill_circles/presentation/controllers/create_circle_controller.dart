import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/skill_circles/domain/repositories/skill_circle_repository.dart';

class CreateCircleController extends StateNotifier<AsyncValue<void>> {
  CreateCircleController(this._repository) : super(const AsyncValue.data(null));

  final SkillCircleRepository _repository;

  Future<void> createCircle({required String name, required String description}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.createCircle(name, description));
  }
}