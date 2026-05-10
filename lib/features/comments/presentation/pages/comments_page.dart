import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/features/comments/presentation/providers/comments_providers.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

class CommentsPage extends ConsumerWidget {
  const CommentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(recentCommentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: commentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load comments: $error', textAlign: TextAlign.center),
          ),
        ),
        data: (comments) {
          if (comments.isEmpty) {
            return const Center(child: Text('No comments yet. Start the conversation.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: comments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final comment = comments[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: ClayTokens.brandPale,
                            child: Text(
                              comment.username.isNotEmpty ? comment.username[0].toUpperCase() : '?',
                              style: const TextStyle(color: ClayTokens.brandDeep, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment.username.isNotEmpty ? comment.username : 'Community Member', style: const TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(comment.postId.isNotEmpty ? 'On post ${comment.postId}' : 'General discussion', style: const TextStyle(color: ClayTokens.textSecond, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(_formatTime(comment.timestamp), style: const TextStyle(color: ClayTokens.textSecond, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(comment.text),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}