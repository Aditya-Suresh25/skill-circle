import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/posts/presentation/controllers/posts_controller.dart';
import 'package:skill_circle_app/features/posts/presentation/providers/posts_providers.dart';

final postsControllerProvider = StateNotifierProvider<PostsController, PostsState>((ref) {
  final repo = ref.read(postRepositoryProvider);
  return PostsController(repo);
});
