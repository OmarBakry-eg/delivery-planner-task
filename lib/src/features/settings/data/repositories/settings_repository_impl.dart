import 'package:flutter/material.dart';
import 'package:test_hsa_group/src/core/config/app_config.dart';
import 'package:test_hsa_group/src/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:test_hsa_group/src/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource local;

  SettingsRepositoryImpl({required this.local});

  @override
  Future<ThemeMode> getThemeMode() async {
    await local.initialize();
    return local.getThemeMode();
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    await local.setThemeMode(mode);
  }

  @override
  Future<BuildFlavor> getEnvironment() async {
    // AppConfig holds env in Hive already
    return AppConfig.flavor;
  }

  @override
  Future<void> setEnvironment(BuildFlavor flavor) async {
    await AppConfig.setFlavorAndPersist(flavor);
  }
}


