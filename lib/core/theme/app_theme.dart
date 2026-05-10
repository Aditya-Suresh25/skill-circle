import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    final textTheme = GoogleFonts.spaceGroteskTextTheme().copyWith(
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        color: ClayTokens.textPrimary,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        color: ClayTokens.textPrimary,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontWeight: FontWeight.w500,
        color: ClayTokens.textPrimary,
      ),
      bodyMedium: GoogleFonts.dmSans(
        color: ClayTokens.textSecond,
      ),
    );

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ClayTokens.textPrimary,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ClayTokens.surface.withValues(alpha: 0.92),
        hintStyle: const TextStyle(color: ClayTokens.textHint),
        labelStyle: const TextStyle(color: ClayTokens.textSecond),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          backgroundColor: ClayTokens.brandDeep,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(ClayTokens.buttonHeight),
          foregroundColor: ClayTokens.brandDeep,
          side: BorderSide(color: ClayTokens.brandLight.withValues(alpha: 0.9)),
          textStyle: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ClayTokens.radiusMD),
          ),
          backgroundColor: ClayTokens.surface.withValues(alpha: 0.75),
        ),
      ),
      cardTheme: CardTheme(
        color: ClayTokens.surface.withValues(alpha: 0.88),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ClayTokens.radiusLG),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ClayTokens.surface.withValues(alpha: 0.95),
        selectedItemColor: ClayTokens.brandDeep,
        unselectedItemColor: ClayTokens.textSecond,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
      ),
    );
  }
}