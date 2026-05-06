import 'package:flutter/material.dart';
import 'package:skill_circle_app/utils/color_theme.dart';

class SkillCircleTheme {
  const SkillCircleTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ClayTokens.brand,
      primary: ClayTokens.brand,
      secondary: ClayTokens.brandMid,
      surface: ClayTokens.surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ClayTokens.pageBg,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ClayTokens.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ClayTokens.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
          borderSide: const BorderSide(color: ClayTokens.brand, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(ClayTokens.buttonHeight),
          backgroundColor: ClayTokens.brand,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: ClayTokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
        ),
      ),
    );
  }
}