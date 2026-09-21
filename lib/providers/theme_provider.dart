import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';

const kHiveBoxParametres = 'parametres';
const _kCleTheme = 'theme_mode';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(_lireThemeInitial());

  static ThemeMode _lireThemeInitial() {
    final box = Hive.box(kHiveBoxParametres);
    final valeur = box.get(_kCleTheme, defaultValue: 'system') as String;
    return _depuisTexte(valeur);
  }

  static ThemeMode _depuisTexte(String v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _versTexte(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> changerTheme(ThemeMode mode) async {
    state = mode;
    await Hive.box(kHiveBoxParametres).put(_kCleTheme, _versTexte(mode));
  }
}
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});