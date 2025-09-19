import 'package:flutter/material.dart';
import 'package:test_hsa_group/src/features/settings/domain/repositories/settings_repository.dart';

class SetThemeMode {
  final SettingsRepository repository;
  const SetThemeMode(this.repository);

  Future<void> call(ThemeMode mode) => repository.setThemeMode(mode);
}


