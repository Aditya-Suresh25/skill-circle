import 'package:flutter/material.dart';

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
            isDark ? const Color(0xFF07070C) : const Color(0xFFF7F4FF),
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
              color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.24 : 0.15),
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
              color: const Color(0xFFA855F7).withValues(alpha: isDark ? 0.22 : 0.12),
              size: 320,
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.08 : 0.04,
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