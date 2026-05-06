import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

class BadgeCard extends StatelessWidget {
  final String badgeTitle;
  final IconData badgeIcon;
  final double? progress; // Optional progress value between 0.0 and 1.0

  const BadgeCard({
    super.key,
    required this.badgeTitle,
    required this.badgeIcon,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    const Color yellowAccent = Color(0xFFFBBF24);

    return Card(
      elevation: 0,
      color: ClayTokens.surface,
      margin: EdgeInsets.zero, // Let the GridView handle spacing
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
          boxShadow: ClayTokens.clayShadow, // Keeping the claymorphism style
        ),
        padding: const EdgeInsets.all(16.0), // Required: Padding 16
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Badge Icon with Yellow Accent ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: yellowAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                badgeIcon,
                color: yellowAccent,
                size: 32,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // ── Badge Title ──
            Text(
              badgeTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: ClayTokens.textSM,
                fontWeight: FontWeight.w800,
                color: ClayTokens.textPrimary,
              ),
            ),
            
            // ── Optional Progress Indicator ──
            if (progress != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 6,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(ClayTokens.radiusFull),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: ClayTokens.pageBg,
                    valueColor: const AlwaysStoppedAnimation<Color>(yellowAccent),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}