import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

class CommentTile extends StatelessWidget {
  final String username;
  final String commentText;

  const CommentTile({
    super.key,
    required this.username,
    required this.commentText,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a simple initial for the avatar
    final initials = username.trim().isEmpty 
        ? '?' 
        : username.trim().substring(0, 1).toUpperCase();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: User Avatar ───────────────────────────────────────────────
          CircleAvatar(
            radius: 18,
            backgroundColor: ClayTokens.brandPale,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: ClayTokens.brand,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // ── Right: Username & Comment Text ──────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: ClayTokens.textSM,
                    fontWeight: FontWeight.w700,
                    color: ClayTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  commentText,
                  style: TextStyle(
                    fontSize: ClayTokens.textSM,
                    color: ClayTokens.textSecond.withValues(alpha: 0.9),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}