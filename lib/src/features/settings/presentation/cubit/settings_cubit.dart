import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/app.dart';
import 'package:test_hsa_group/src/core/config/app_config.dart';
import 'package:test_hsa_group/src/features/auth/domain/usecases/logout.dart';
import 'package:test_hsa_group/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:test_hsa_group/src/features/home/presentation/cubit/home_cubit.dart';
import 'package:test_hsa_group/src/features/settings/domain/usecases/get_theme_mode.dart';
import 'package:test_hsa_group/src/features/settings/domain/usecases/set_environment.dart';
import 'package:test_hsa_group/src/features/settings/domain/usecases/set_theme_mode.dart';
import 'package:test_hsa_group/src/features/settings/presentation/cubit/settings_state.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_cubit.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetThemeMode getThemeModeUseCase;
  final SetThemeMode setThemeModeUseCase;
  final SetEnvironment setEnvironmentUseCase;
  final LogoutUseCase logoutUseCase;

  SettingsCubit({
    required this.getThemeModeUseCase,
    required this.setThemeModeUseCase,
    required this.setEnvironmentUseCase,
    required this.logoutUseCase,
  }) : super(
         const SettingsState(
           themeMode: ThemeMode.system,
           flavor: BuildFlavor.prod,
         ),
       );

  Future<void> initialize() async {
    final mode = await getThemeModeUseCase();
    emit(state.copyWith(themeMode: mode, flavor: AppConfig.flavor));
  }

  Future<void> changeTheme(ThemeMode mode) async {
    emit(state.copyWith(isBusy: true));
    await setThemeModeUseCase(mode);
    emit(state.copyWith(themeMode: mode, isBusy: false));
  }

  Future<void> changeEnvironment(
    BuildContext context,
    BuildFlavor flavor,
  ) async {
    emit(state.copyWith(isBusy: true));
    await setEnvironmentUseCase(flavor);
    if (context.mounted) {
      context.read<TripPlanningCubit>().loadData();
      await logout(context);
    }

    emit(state.copyWith(flavor: flavor, isBusy: false));
  }

  Future<void> logout(BuildContext context) async {
    emit(state.copyWith(isBusy: true));
    await logoutUseCase();
    if (context.mounted) {
      await context.read<AuthCubit>().signOut();
      if (context.mounted) {
        context.read<HomeCubit>().setSelectedIndex(0);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (route) => false,
        );
      }
    }
    emit(state.copyWith(isBusy: false));
  }
}
