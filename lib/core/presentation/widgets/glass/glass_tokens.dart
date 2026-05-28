import 'package:flutter/material.dart';

class GlassTokens {
  const GlassTokens._();

  static const double radiusLg = 24;
  static const double radiusMd = 20;

  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(16, 12, 16, 24);
  static const EdgeInsets panelPadding = EdgeInsets.all(16);
  static const EdgeInsets panelPaddingDense = EdgeInsets.all(14);

  static const Duration motionFast = Duration(milliseconds: 220);
  static const Duration motionNormal = Duration(milliseconds: 320);
  static const Duration motionSlow = Duration(milliseconds: 460);

  static const Curve motionCurve = Curves.easeOutCubic;

  static const double titleSize = 26;
  static const double sectionTitleSize = 18;
  static const double bodySize = 14;
}
