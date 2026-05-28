import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:skill_circle_app/core/presentation/widgets/glass/glass_tokens.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = GlassTokens.panelPadding,
    this.radius = GlassTokens.radiusLg,
    this.blurSigma = 16,
    this.useAnimatedEntrance = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final double blurSigma;
  final bool useAnimatedEntrance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final panel = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.white.withValues(alpha: 0.12), Colors.white.withValues(alpha: 0.05)]
                  : [Colors.white.withValues(alpha: 0.74), Colors.white.withValues(alpha: 0.54)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.88),
            ),
          ),
          child: child,
        ),
      ),
    );

    if (!useAnimatedEntrance) return panel;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: GlassTokens.motionNormal,
      curve: GlassTokens.motionCurve,
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: ((value - 0.96) / 0.04).clamp(0, 1),
            child: panel,
          ),
        );
      },
    );
  }
}
