import 'package:flutter/material.dart';
import 'package:skill_circle_app/core/presentation/widgets/glass/glass_panel.dart';
import 'package:skill_circle_app/core/presentation/widgets/glass/glass_tokens.dart';

class GlassPageHeader extends StatelessWidget {
  const GlassPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF2A1C3F);
    final subtitleColor = isDark ? const Color(0xFFD4CEE4) : const Color(0xFF66597D);

    return GlassPanel(
      useAnimatedEntrance: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: GlassTokens.titleSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: subtitleColor, height: 1.35)),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
