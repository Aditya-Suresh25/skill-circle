import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SkillCircleTheme {
  const SkillCircleTheme._();

  static ThemeData light() {
    const bg = Color(0xFFF5F3FF);
    const surface = Color(0xFFFFFFFF);
    const surface2 = Color(0xFFF4F0FF);
    const primary = Color(0xFF7C3AED);
    const primary2 = Color(0xFFA855F7);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: primary2,
      surface: surface,
      brightness: Brightness.light,
    );

    final textTheme = GoogleFonts.soraTextTheme().copyWith(
      headlineMedium: GoogleFonts.sora(fontWeight: FontWeight.w700, color: const Color(0xFF1C1234)),
      titleLarge: GoogleFonts.sora(fontWeight: FontWeight.w700, color: const Color(0xFF1C1234)),
      titleMedium: GoogleFonts.sora(fontWeight: FontWeight.w600, color: const Color(0xFF2E1D56)),
      bodyLarge: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: const Color(0xFF2D2348)),
      bodyMedium: GoogleFonts.outfit(color: const Color(0xFF5B4B83)),
      labelLarge: GoogleFonts.sora(fontWeight: FontWeight.w600, color: Colors.white),
    );

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: bg,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1C1234),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        hintStyle: const TextStyle(color: Color(0xFF8E80AE)),
        labelStyle: const TextStyle(color: Color(0xFF665792)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primary2, width: 1.3),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: const Color(0xFF2E1D56),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.10)),
          textStyle: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF8A80A7),
        elevation: 0,
        selectedLabelStyle: GoogleFonts.sora(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
      ),
    );
  }

  static ThemeData dark() {
    const bg = Color(0xFF0A0A0F);
    const surface = Color(0xFF13131D);
    const surface2 = Color(0xFF1A1A24);
    const primary = Color(0xFF8B5CF6);
    const primary2 = Color(0xFFC084FC);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: primary2,
      surface: surface,
      brightness: Brightness.dark,
    );

    final textTheme = GoogleFonts.soraTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineMedium: GoogleFonts.sora(fontWeight: FontWeight.w700, color: Colors.white),
      titleLarge: GoogleFonts.sora(fontWeight: FontWeight.w700, color: Colors.white),
      titleMedium: GoogleFonts.sora(fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: const Color(0xFFF5F5F5)),
      bodyMedium: GoogleFonts.outfit(color: const Color(0xFFE6E6F0)),
      labelLarge: GoogleFonts.sora(fontWeight: FontWeight.w600, color: Colors.white),
    );

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: bg,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2.withValues(alpha: 0.72),
        hintStyle: const TextStyle(color: Color(0xFF9A9AAE)),
        labelStyle: const TextStyle(color: Color(0xFFC7C7D9)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primary2, width: 1.3),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
          shadowColor: primary.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          textStyle: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: surface.withValues(alpha: 0.55),
        ),
      ),
      cardTheme: CardTheme(
        color: surface.withValues(alpha: 0.76),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: 0.95),
        selectedItemColor: primary2,
        unselectedItemColor: const Color(0xFF9595A9),
        elevation: 0,
        selectedLabelStyle: GoogleFonts.sora(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
      ),
    );
  }
}