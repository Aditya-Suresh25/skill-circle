import 'package:skill_circle_app/features/skill_circles/domain/entities/skill_circle.dart';

class PaginatedSkillCircles {
  PaginatedSkillCircles({required this.circles, this.lastCursorId});

  final List<SkillCircle> circles;
  final String? lastCursorId;
}

abstract class SkillCircleRepository {
  /// Stream of all circles (small lists / for realtime sections)
  Stream<List<SkillCircle>> watchSkillCircles({int limit = 50});

  /// Fetch page of circles with optional startAfter doc for pagination
  Future<PaginatedSkillCircles> fetchCirclesPage({required int limit, String? startAfterId});

  /// Create a new circle for the signed-in user
  Future<void> createCircle({
    required String name,
    required String description,
    String? imageUrl,
    String? bannerUrl,
  });

  /// Create or update a circle
  Future<void> saveSkillCircle(SkillCircle circle);

  /// Join a circle (adds userId to members and increments count)
  Future<void> joinCircle(String circleId, String userId);

  /// Leave a circle (removes userId and decrements count)
  Future<void> leaveCircle(String circleId, String userId);

  /// Stream of circles joined by a user
  Stream<List<SkillCircle>> watchJoinedCircles(String userId, {int limit = 50});
}