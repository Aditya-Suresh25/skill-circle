import 'package:flutter/material.dart';

/// App-supported theme variants.
enum AppThemeType {
  clay,
  ocean,
  forest,
  sunset,
}

/// Structured color set used across the app.
class AppColorTheme {
  final Color brand;
  final Color brandMid;
  final Color brandLight;
  final Color brandPale;
  final Color brandDeep;
  final Color pageBg;
  final Color surface;
  final Color textPrimary;
  final Color textSecond;
  final Color textHint;
  final Color error;
  final Color success;

  const AppColorTheme({
    required this.brand,
    required this.brandMid,
    required this.brandLight,
    required this.brandPale,
    required this.brandDeep,
    required this.pageBg,
    required this.surface,
    required this.textPrimary,
    required this.textSecond,
    required this.textHint,
    required this.error,
    required this.success,
  });
}

/// Central registry to store and retrieve color themes.
class AppThemeRegistry {
  AppThemeRegistry._();

  static const Map<AppThemeType, AppColorTheme> _themes = {
    AppThemeType.clay: AppColorTheme(
      brand: Color(0xFF7C3AED),
      brandMid: Color(0xFF8B5CF6),
      brandLight: Color(0xFFA78BFA),
      brandPale: Color(0xFFEDE9FE),
      brandDeep: Color(0xFF6D28D9),
      pageBg: Color(0xFFF5F3FF),
      surface: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF1E1B4B),
      textSecond: Color(0xFF6D5FA6),
      textHint: Color(0xFFBDB4E2),
      error: Color(0xFFEF4444),
      success: Color(0xFF10B981),
    ),
    AppThemeType.ocean: AppColorTheme(
      brand: Color(0xFF0EA5E9),
      brandMid: Color(0xFF38BDF8),
      brandLight: Color(0xFF7DD3FC),
      brandPale: Color(0xFFE0F2FE),
      brandDeep: Color(0xFF0369A1),
      pageBg: Color(0xFFF0F9FF),
      surface: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF082F49),
      textSecond: Color(0xFF0369A1),
      textHint: Color(0xFF7BA6C2),
      error: Color(0xFFDC2626),
      success: Color(0xFF059669),
    ),
    AppThemeType.forest: AppColorTheme(
      brand: Color(0xFF16A34A),
      brandMid: Color(0xFF22C55E),
      brandLight: Color(0xFF86EFAC),
      brandPale: Color(0xFFDCFCE7),
      brandDeep: Color(0xFF166534),
      pageBg: Color(0xFFF0FDF4),
      surface: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF14532D),
      textSecond: Color(0xFF166534),
      textHint: Color(0xFF7AA690),
      error: Color(0xFFDC2626),
      success: Color(0xFF16A34A),
    ),
    AppThemeType.sunset: AppColorTheme(
      brand: Color(0xFFF97316),
      brandMid: Color(0xFFFB923C),
      brandLight: Color(0xFFFDBA74),
      brandPale: Color(0xFFFFEDD5),
      brandDeep: Color(0xFFC2410C),
      pageBg: Color(0xFFFFF7ED),
      surface: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF7C2D12),
      textSecond: Color(0xFFC2410C),
      textHint: Color(0xFFCEA489),
      error: Color(0xFFDC2626),
      success: Color(0xFF059669),
    ),
  };

  static AppColorTheme of(AppThemeType type) {
    return _themes[type] ?? _themes[AppThemeType.clay]!;
  }

  static AppColorTheme byName(String value) {
    final normalized = value.toLowerCase().trim();
    for (final entry in _themes.entries) {
      if (entry.key.name == normalized) {
        return entry.value;
      }
    }
    return _themes[AppThemeType.clay]!;
  }

  static List<AppThemeType> get supportedThemes => _themes.keys.toList(growable: false);
}

/// Backward-compatible design tokens used by current screens.
///
/// This keeps existing widgets unchanged while colors come from one source.
class ClayTokens {
  ClayTokens._();

  // Keep compile-time constants so existing `const` widgets remain valid.
  static const Color brand = Color(0xFF7C3AED);
  static const Color brandMid = Color(0xFF8B5CF6);
  static const Color brandLight = Color(0xFFA78BFA);
  static const Color brandPale = Color(0xFFEDE9FE);
  static const Color brandDeep = Color(0xFF6D28D9);

  static const Color pageBg = Color(0xFFF5F3FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E1B4B);
  static const Color textSecond = Color(0xFF6D5FA6);
  static const Color textHint = Color(0xFFBDB4E2);

  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 24.0;
  static const double radiusXL = 28.0;
  static const double radiusFull = 999.0;

  static const double minTouch = 48.0;
  static const double buttonHeight = 56.0;
  static const double fieldHeight = 54.0;

  static const double textXS = 11.0;
  static const double textSM = 13.0;
  static const double textBase = 15.0;
  static const double textLG = 18.0;
  static const double textXL = 24.0;
  static const double textXXL = 30.0;

  static List<BoxShadow> get clayShadow => [
        BoxShadow(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.90),
          offset: const Offset(-5, -5),
          blurRadius: 12,
        ),
        BoxShadow(
          color: brandLight.withValues(alpha: 0.50),
          offset: const Offset(5, 5),
          blurRadius: 16,
        ),
      ];

  static List<BoxShadow> get clayAvatar => [
        BoxShadow(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.80),
          offset: const Offset(-3, -3),
          blurRadius: 8,
        ),
        BoxShadow(
          color: brandLight.withValues(alpha: 0.45),
          offset: const Offset(3, 3),
          blurRadius: 10,
        ),
      ];

  static List<BoxShadow> get clayField => [
        BoxShadow(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.85),
          offset: const Offset(-4, -4),
          blurRadius: 10,
        ),
        BoxShadow(
          color: brandLight.withValues(alpha: 0.50),
          offset: const Offset(4, 4),
          blurRadius: 12,
        ),
      ];

  static List<BoxShadow> get clayButton => [
        BoxShadow(
          color: brand.withValues(alpha: 0.40),
          offset: const Offset(0, 6),
          blurRadius: 16,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.30),
          offset: const Offset(0, -1),
          blurRadius: 4,
        ),
      ];

  static Color blob(Color base, double alpha) => base.withValues(alpha: alpha);
}
