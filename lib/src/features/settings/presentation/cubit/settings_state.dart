import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:test_hsa_group/src/core/config/app_config.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final BuildFlavor flavor;
  final bool isBusy;

  const SettingsState({
    required this.themeMode,
    required this.flavor,
    this.isBusy = false,
  });

  SettingsState copyWith({ThemeMode? themeMode, BuildFlavor? flavor, bool? isBusy}) => SettingsState(
    themeMode: themeMode ?? this.themeMode,
    flavor: flavor ?? this.flavor,
    isBusy: isBusy ?? this.isBusy,
  );

  @override
  List<Object?> get props => [themeMode, flavor, isBusy];
}


