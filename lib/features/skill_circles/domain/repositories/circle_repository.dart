import 'package:skill_circle_app/features/skill_circles/domain/entities/skill_circle.dart';

abstract class CircleRepository {
  Future<void> createCircle(String name, String description);

  Future<void> joinCircle(String circleId, String userId);

  Future<void> leaveCircle(String circleId, String userId);

  Future<void> saveSkillCircle(SkillCircle circle);
}