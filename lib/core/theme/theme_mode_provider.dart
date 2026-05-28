import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'skill_circle.theme_mode';

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController()..load();
});

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.dark);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeModeKey);
    if (raw == ThemeMode.light.name) {
      state = ThemeMode.light;
      return;
    }
    if (raw == ThemeMode.dark.name) {
      state = ThemeMode.dark;
      return;
    }
    state = ThemeMode.dark;
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(next);
  }
}
