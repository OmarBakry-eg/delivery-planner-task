import 'package:flutter/material.dart';
import 'package:test_hsa_group/src/core/config/app_config.dart';

abstract class SettingsRepository {
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);

  Future<BuildFlavor> getEnvironment();
  Future<void> setEnvironment(BuildFlavor flavor);
}


