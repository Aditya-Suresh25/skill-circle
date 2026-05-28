import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_circle_app/core/presentation/widgets/aurora_background.dart';
import 'package:skill_circle_app/core/presentation/widgets/glass/glass.dart';
import 'package:skill_circle_app/features/comments/presentation/providers/comments_providers.dart';

class CommentsPage extends ConsumerWidget {
  const CommentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(recentCommentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF251A3A);
    final subtitleColor = isDark ? const Color(0xFFCAC3DD) : const Color(0xFF5F5674);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Comments',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Track the latest conversation threads across your community circles.',
                        style: TextStyle(color: subtitleColor, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: commentsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Failed to load comments: $error', textAlign: TextAlign.center),
                    ),
                  ),
                  data: (comments) {
                    if (comments.isEmpty) {
                      return Center(
                        child: GlassPanel(
                          child: Text(
                            'No comments yet. Start the conversation.',
                            style: TextStyle(color: subtitleColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final username = comment.username.isNotEmpty ? comment.username : 'Community Member';
                        final initial = username[0].toUpperCase();

                        return GlassPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? const [Color(0xFFC084FC), Color(0xFF8B5CF6)]
                                            : const [Color(0xFFA855F7), Color(0xFF6D28D9)],
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        initial,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          username,
                                          style: TextStyle(
                                            color: titleColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          comment.postId.isNotEmpty ? 'On post ${comment.postId}' : 'General discussion',
                                          style: TextStyle(color: subtitleColor, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(_formatTime(comment.timestamp), style: TextStyle(color: subtitleColor, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(comment.text, style: TextStyle(color: titleColor, height: 1.4)),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
