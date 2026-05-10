import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7F8EA),
            Color(0xFFEFFBF7),
            Color(0xFFE8F4FA),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -40,
            child: _GlowBlob(
              color: ClayTokens.brandLight.withValues(alpha: 0.50),
              size: 220,
            ),
          ),
          Positioned(
            top: 160,
            right: -60,
            child: _GlowBlob(
              color: const Color(0xFFFFD6A6).withValues(alpha: 0.45),
              size: 200,
            ),
          ),
          Positioned(
            bottom: -90,
            left: 60,
            child: _GlowBlob(
              color: ClayTokens.brandPale.withValues(alpha: 0.70),
              size: 240,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 80,
              spreadRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}