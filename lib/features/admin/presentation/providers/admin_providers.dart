import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/providers/appwrite_storage_providers.dart';
import 'package:skill_circle_app/features/admin/data/appwrite_admin_repository.dart';
import 'package:skill_circle_app/features/admin/domain/admin_repository.dart';
import 'package:skill_circle_app/features/posts/domain/entities/post.dart';
import 'package:skill_circle_app/features/profile/domain/entities/profile.dart';
import 'package:skill_circle_app/features/skill_circles/domain/entities/skill_circle.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AppwriteAdminRepository(
    ref.read(appwriteDatabasesProvider),
    ref.read(appwriteStorageConfigProvider),
  );
});

final adminUsersProvider = FutureProvider<List<Profile>>((ref) async {
  return ref.read(adminRepositoryProvider).listUsers();
});

final adminCirclesProvider = FutureProvider<List<SkillCircle>>((ref) async {
  return ref.read(adminRepositoryProvider).listCircles();
});

final adminPostsProvider = FutureProvider<List<Post>>((ref) async {
  return ref.read(adminRepositoryProvider).listPosts();
});
