import 'package:flutter/material.dart';
import 'package:test_hsa_group/src/features/settings/domain/repositories/settings_repository.dart';

class GetThemeMode {
  final SettingsRepository repository;
  const GetThemeMode(this.repository);

  Future<ThemeMode> call() => repository.getThemeMode();
}


