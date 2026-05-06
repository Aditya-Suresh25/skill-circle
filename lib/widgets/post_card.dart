import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

class PostCard extends StatelessWidget {
  final String username;
  final String title;
  final String contentPreview;

  const PostCard({
    super.key,
    required this.username,
    required this.title,
    required this.contentPreview,
  });

  /// Generates a consistent accent color based on the username string
  Color _accentFromName(String name) {
    const accents = [
      Color(0xFF7C3AED), Color(0xFF8B5CF6), Color(0xFF6D28D9),
      Color(0xFF9333EA), Color(0xFF7E22CE), Color(0xFFA855F7),
    ];
    final idx = name.codeUnits.fold(0, (a, b) => a + b) % accents.length;
    return accents[idx];
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentFromName(username);
    final initials = username.trim().isEmpty 
        ? '?' 
        : username.trim().substring(0, 1).toUpperCase();

    return Card(
      elevation: 0,
      color: ClayTokens.surface,
      margin: const EdgeInsets.only(bottom: ClayTokens.spaceMD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
      ),
      // Mimicking the clay shadow using the card's container
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
          boxShadow: ClayTokens.clayShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Required: Padding 16
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Avatar & Username ──
              Row(
                children: [
                  // User Avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Username
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: ClayTokens.textSM,
                      fontWeight: FontWeight.w700,
                      color: ClayTokens.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.more_vert_rounded, size: 18, color: ClayTokens.textHint),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // ── Post Title ──
              Text(
                title,
                style: const TextStyle(
                  fontSize: ClayTokens.textBase,
                  fontWeight: FontWeight.w800,
                  color: ClayTokens.textPrimary,
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // ── Content Preview ──
              Text(
                contentPreview,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ClayTokens.textSM,
                  color: ClayTokens.textSecond.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // ── Action Bar: Like & Comment Icons ──
              Row(
                children: [
                  _PostActionButton(
                    icon: Icons.favorite_border_rounded,
                    label: 'Like',
                    color: ClayTokens.error,
                  ),
                  const SizedBox(width: 24),
                  _PostActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Comment',
                    color: ClayTokens.textSecond,
                  ),
                  const Spacer(),
                  const Icon(Icons.share_rounded, size: 18, color: ClayTokens.textHint),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widget for action buttons
// ─────────────────────────────────────────────────────────────────────────────
class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PostActionButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ClayTokens.textSecond.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}