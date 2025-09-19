import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class SettingsLocalDataSource {
  static const String _boxName = 'settings_box';
  static const String _themeKey = 'theme_mode';

  Box? _box;

  Future<void> initialize() async {
    _box = Hive.isBoxOpen(_boxName)
        ? Hive.box(_boxName)
        : await Hive.openBox(_boxName);
  }

  Future<ThemeMode> getThemeMode() async {
    await _ensure();
    final value = _box!.get(_themeKey) as String?;
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _ensure();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await _box!.put(_themeKey, value);
  }

  Future<void> _ensure() async {
    if (_box == null || !_box!.isOpen) {
      await initialize();
    }
  }
}
