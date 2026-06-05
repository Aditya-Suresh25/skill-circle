import 'dart:ui';
import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22.0,
    this.blurSigma = 12.0,
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
    final accent = isDark ? const Color(0xFF8B5CF6) : const Color(0xFFA855F7);

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
                  ? [Colors.white.withValues(alpha: 0.10), Colors.white.withValues(alpha: 0.045)]
                  : [Colors.white.withValues(alpha: 0.82), Colors.white.withValues(alpha: 0.60)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.92),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.10 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (!useAnimatedEntrance) return panel;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
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

class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? const Color(0xFF07070B) : const Color(0xFFF8F5FF),
            isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF3EDFF),
            isDark ? const Color(0xFF11111A) : const Color(0xFFF0E8FF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _GlowBlob(
              color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.18 : 0.12),
              size: 320,
            ),
          ),
          Positioned(
            top: 120,
            right: -70,
            child: _GlowBlob(
              color: const Color(0xFFC084FC).withValues(alpha: isDark ? 0.18 : 0.12),
              size: 280,
            ),
          ),
          Positioned(
            bottom: -120,
            left: 40,
            child: _GlowBlob(
              color: const Color(0xFFA855F7).withValues(alpha: isDark ? 0.16 : 0.10),
              size: 320,
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.06 : 0.03,
              child: CustomPaint(
                painter: _NoisePainter(),
              ),
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

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    const gap = 24.0;
    for (var y = 0.0; y < size.height; y += gap) {
      for (var x = 0.0; x < size.width; x += gap) {
        if (((x + y) ~/ gap) % 3 == 0) {
          canvas.drawCircle(Offset(x + 3, y + 4), 0.7, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
