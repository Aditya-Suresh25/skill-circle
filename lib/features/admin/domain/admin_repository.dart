import 'package:skill_circle_app/features/posts/domain/entities/post.dart';
import 'package:skill_circle_app/features/profile/domain/entities/profile.dart';
import 'package:skill_circle_app/features/skill_circles/domain/entities/skill_circle.dart';

abstract class AdminRepository {
  Future<List<Profile>> listUsers({int limit = 50});
  Future<List<SkillCircle>> listCircles({int limit = 50});
  Future<List<Post>> listPosts({int limit = 50});
  Future<void> deleteCircle(String circleId);
  Future<void> deletePost(String postId);
}
