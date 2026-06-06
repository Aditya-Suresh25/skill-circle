import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_circle_app/core/constants/app_colors.dart';

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
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.twitchPurple,
      primary: AppColors.twitchPurple,
      secondary: AppColors.twitchPurpleLight,
      surface: AppColors.lightSurface,
      brightness: Brightness.light,
    );

    final textTheme = GoogleFonts.lexendTextTheme().copyWith(
      displayLarge: GoogleFonts.lexend(fontWeight: FontWeight.w800, color: AppColors.lightTextPrimary),
      headlineLarge: GoogleFonts.lexend(fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary),
      headlineMedium: GoogleFonts.lexend(fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary),
      titleLarge: GoogleFonts.lexend(fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary),
      titleMedium: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: AppColors.twitchPurple),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w500, color: AppColors.lightTextPrimary),
      bodyMedium: GoogleFonts.inter(color: AppColors.lightTextSecondary),
      bodySmall: GoogleFonts.inter(color: AppColors.lightTextSecondary.withValues(alpha: 0.8)),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: AppColors.lightTextSecondary),
    );

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.lightBg,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightTextPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface2,
        hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
        labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.twitchPurple, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: AppColors.twitchPurple,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
          shadowColor: AppColors.twitchPurple.withValues(alpha: 0.30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: AppColors.twitchPurple,
          side: const BorderSide(color: AppColors.lightBorder),
          textStyle: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface.withValues(alpha: 0.90),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurface2,
        selectedColor: AppColors.twitchPurple.withValues(alpha: 0.18),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, color: AppColors.lightTextPrimary),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.lightBorder, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurface,
        contentTextStyle: GoogleFonts.inter(color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.lightSurface.withValues(alpha: 0.96),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface.withValues(alpha: 0.96),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface.withValues(alpha: 0.92),
        selectedItemColor: AppColors.twitchPurple,
        unselectedItemColor: AppColors.lightTextSecondary,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.twitchPurple,
      primary: AppColors.twitchPurple,
      secondary: AppColors.twitchPurpleLight,
      surface: AppColors.darkSurface,
      brightness: Brightness.dark,
    );

    final textTheme = GoogleFonts.lexendTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.lexend(fontWeight: FontWeight.w800, color: AppColors.darkTextPrimary),
      headlineLarge: GoogleFonts.lexend(fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary),
      headlineMedium: GoogleFonts.lexend(fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary),
      titleLarge: GoogleFonts.lexend(fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary),
      titleMedium: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w500, color: AppColors.darkTextPrimary),
      bodyMedium: GoogleFonts.inter(color: AppColors.darkTextSecondary),
      bodySmall: GoogleFonts.inter(color: AppColors.darkTextSecondary.withValues(alpha: 0.8)),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: AppColors.darkTextSecondary),
    );

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.darkBg,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface2.withValues(alpha: 0.82),
        hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.twitchPurple, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: AppColors.twitchPurple,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
          shadowColor: AppColors.twitchPurple.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: Colors.white,
          side: const BorderSide(color: AppColors.darkBorder),
          textStyle: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.darkSurface.withValues(alpha: 0.62),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface.withValues(alpha: 0.82),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface2.withValues(alpha: 0.78),
        selectedColor: AppColors.twitchPurple.withValues(alpha: 0.22),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white),
      ),
      dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.08), thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF12121A),
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.darkSurface.withValues(alpha: 0.96),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface.withValues(alpha: 0.96),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface.withValues(alpha: 0.95),
        selectedItemColor: AppColors.twitchPurpleLight,
        unselectedItemColor: const Color(0xFF9595A9),
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
      ),
    );
  }
}

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;
  Color get textColor => textTheme.bodyLarge?.color ?? Colors.white;
}
