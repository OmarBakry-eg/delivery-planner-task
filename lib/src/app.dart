import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/init.dart';
import 'package:test_hsa_group/src/core/config/app_config.dart';
import 'package:test_hsa_group/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:test_hsa_group/src/features/auth/domain/usecases/get_auth_status.dart';
import 'package:test_hsa_group/src/features/auth/domain/usecases/login.dart';
import 'package:test_hsa_group/src/features/auth/domain/usecases/logout.dart';
import 'package:test_hsa_group/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:test_hsa_group/src/features/auth/presentation/cubit/auth_state.dart';
import 'package:test_hsa_group/src/features/auth/presentation/view/screens/login_screen.dart';
import 'package:test_hsa_group/src/features/home/presentation/cubit/home_cubit.dart';
import 'package:test_hsa_group/src/features/home/presentation/screens/home_page.dart';
import 'package:test_hsa_group/src/features/settings/domain/repositories/settings_repository.dart';
import 'package:test_hsa_group/src/features/settings/domain/usecases/get_theme_mode.dart';
import 'package:test_hsa_group/src/features/settings/domain/usecases/set_environment.dart';
import 'package:test_hsa_group/src/features/settings/domain/usecases/set_theme_mode.dart';
import 'package:test_hsa_group/src/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:test_hsa_group/src/features/settings/presentation/cubit/settings_state.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/cubit/trip_execution_cubit.dart';
import 'package:test_hsa_group/src/features/trip_planning/data/repo/trip_repo.dart';
import 'package:test_hsa_group/src/features/trip_planning/presentation/cubit/trip_planning_cubit.dart';
import 'package:test_hsa_group/src/theme/app_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TripPlanningRepository tripRepository;
  late final AuthRepository authRepository;
  late final TripPlanningCubit _tripPlanningCubit;
  late final HomeCubit _homeCubit;
  late final TripExecutionCubit _tripExecutionCubit;

  @override
  void dispose() {
    _tripPlanningCubit.close();
    _homeCubit.close();
    _tripExecutionCubit.close();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    tripRepository = getIt<TripPlanningRepository>();
    authRepository = getIt<AuthRepository>();
    _tripPlanningCubit = TripPlanningCubit(tripRepository)..loadData();
    _homeCubit = HomeCubit();
    _tripExecutionCubit = TripExecutionCubit(tripRepository);
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<TripPlanningRepository>.value(
      value: tripRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              getStatus: GetAuthStatusUseCase(authRepository),
              loginUseCase: LoginUseCase(authRepository),
              logoutUseCase: LogoutUseCase(authRepository),
            )..checkAuthOnStart(),
          ),
          BlocProvider<TripPlanningCubit>.value(value: _tripPlanningCubit),
          BlocProvider<HomeCubit>.value(value: _homeCubit),
          BlocProvider<TripExecutionCubit>.value(value: _tripExecutionCubit),
        ],
        child: BlocProvider<SettingsCubit>(
          create: (context) {
            final SettingsRepository settingsRepo = getIt<SettingsRepository>();
            final cubit = SettingsCubit(
              getThemeModeUseCase: GetThemeMode(settingsRepo),
              setThemeModeUseCase: SetThemeMode(settingsRepo),
              setEnvironmentUseCase: SetEnvironment(settingsRepo),
              logoutUseCase: LogoutUseCase(authRepository),
            );
            cubit.initialize();
            return cubit;
          },
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settings) {
              return MaterialApp(
                title: AppConfig.appName,
                debugShowCheckedModeBanner: false,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: settings.themeMode,
                home: const AuthGate(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuthAuthenticated) {
          return const HomePage();
        }
        return const LoginScreen();
      },
    );
  }
}
