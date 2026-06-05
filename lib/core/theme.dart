import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  static const _prefKey = 'theme_mode';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_prefKey);
      if (name != null) {
        state = ThemeMode.values.firstWhere((e) => e.name == name, orElse: () => ThemeMode.dark);
      }
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, next.name);
    } catch (_) {}
  }
}

class SkillCircleTheme {
  const SkillCircleTheme._();

  static ThemeData light() {
    const bg = Color(0xFFF6F2FF);
    const surface = Color(0xFFFFFFFF);
    const surface2 = Color(0xFFF4F0FF);
    const primary = Color(0xFF7C3AED);
    const primary2 = Color(0xFFA855F7);
    const accent = Color(0xFFC084FC);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: primary2,
      surface: surface,
      brightness: Brightness.light,
    );

    final textTheme = GoogleFonts.soraTextTheme().copyWith(
      displayLarge: GoogleFonts.sora(fontWeight: FontWeight.w800, color: const Color(0xFF1D1430)),
      headlineLarge: GoogleFonts.sora(fontWeight: FontWeight.w700, color: const Color(0xFF1D1430)),
      headlineMedium: GoogleFonts.sora(fontWeight: FontWeight.w700, color: const Color(0xFF1D1430)),
      titleLarge: GoogleFonts.sora(fontWeight: FontWeight.w700, color: const Color(0xFF1D1430)),
      titleMedium: GoogleFonts.sora(fontWeight: FontWeight.w600, color: const Color(0xFF2E1D56)),
      bodyLarge: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: const Color(0xFF2D2348)),
      bodyMedium: GoogleFonts.outfit(color: const Color(0xFF5B4B83)),
      bodySmall: GoogleFonts.poppins(color: const Color(0xFF7E7398)),
      labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
      labelMedium: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: const Color(0xFF5B4B83)),
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
        foregroundColor: Color(0xFF1D1430),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF2A1C43)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        hintStyle: const TextStyle(color: Color(0xFF8A7AAE)),
        labelStyle: const TextStyle(color: Color(0xFF665792)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: accent, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
          shadowColor: primary.withValues(alpha: 0.30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: surface.withValues(alpha: 0.90),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface2,
        selectedColor: accent.withValues(alpha: 0.18),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: const Color(0xFF2B1C48)),
      ),
      dividerTheme: DividerThemeData(color: const Color(0xFF2B1C48).withValues(alpha: 0.08), thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1B142A),
        contentTextStyle: GoogleFonts.outfit(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white.withValues(alpha: 0.96),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.96),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF8A80A7),
        elevation: 0,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    );
  }

  static ThemeData dark() {
    const bg = Color(0xFF09090E);
    const surface = Color(0xFF12121A);
    const surface2 = Color(0xFF1B1B26);
    const primary = Color(0xFF8B5CF6);
    const primary2 = Color(0xFFC084FC);
    const accent = Color(0xFFA855F7);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: primary2,
      surface: surface,
      brightness: Brightness.dark,
    );

    final textTheme = GoogleFonts.soraTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.sora(fontWeight: FontWeight.w800, color: Colors.white),
      headlineLarge: GoogleFonts.sora(fontWeight: FontWeight.w700, color: Colors.white),
      headlineMedium: GoogleFonts.sora(fontWeight: FontWeight.w700, color: Colors.white),
      titleLarge: GoogleFonts.sora(fontWeight: FontWeight.w700, color: Colors.white),
      titleMedium: GoogleFonts.sora(fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: const Color(0xFFF5F5F5)),
      bodyMedium: GoogleFonts.outfit(color: const Color(0xFFE6E6F0)),
      bodySmall: GoogleFonts.poppins(color: const Color(0xFFB8B8CB)),
      labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
      labelMedium: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: const Color(0xFFD8D3E8)),
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
      iconTheme: const IconThemeData(color: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2.withValues(alpha: 0.82),
        hintStyle: const TextStyle(color: Color(0xFF9A9AAE)),
        labelStyle: const TextStyle(color: Color(0xFFC7C7D9)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: accent, width: 1.4),
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
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
          textStyle: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: surface.withValues(alpha: 0.62),
        ),
      ),
      cardTheme: CardTheme(
        color: surface.withValues(alpha: 0.82),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface2.withValues(alpha: 0.78),
        selectedColor: primary.withValues(alpha: 0.22),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white),
      ),
      dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.08), thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF12121A),
        contentTextStyle: GoogleFonts.outfit(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface.withValues(alpha: 0.96),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface.withValues(alpha: 0.96),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: 0.95),
        selectedItemColor: primary2,
        unselectedItemColor: const Color(0xFF9595A9),
        elevation: 0,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    );
  }
}
