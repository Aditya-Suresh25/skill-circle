import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/comments/presentation/controllers/comments_controller.dart';
import 'package:skill_circle_app/features/comments/presentation/providers/comments_providers.dart';

final commentsControllerProvider = StateNotifierProvider<CommentsController, CommentsState>((ref) {
  final repo = ref.read(commentRepositoryProvider);
  return CommentsController(repo);
});
