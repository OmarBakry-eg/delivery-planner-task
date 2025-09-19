import 'package:get_it/get_it.dart';
import 'package:test_hsa_group/src/core/config/app_config.dart';
import 'package:test_hsa_group/src/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:test_hsa_group/src/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:test_hsa_group/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:test_hsa_group/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:test_hsa_group/src/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:test_hsa_group/src/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:test_hsa_group/src/features/settings/domain/repositories/settings_repository.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/cubit/trip_execution_cubit.dart';
import 'package:test_hsa_group/src/features/trip_planning/data/repo/trip_repo.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Initialize app-wide services and storage once
  await AppConfig.initialize();

  // Data sources
  final authLocal = AuthLocalDataSource();
  await authLocal.initialize();
  getIt.registerSingleton<AuthLocalDataSource>(authLocal);
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(),
  );

  final settingsLocal = SettingsLocalDataSource();
  await settingsLocal.initialize();
  getIt.registerSingleton<SettingsLocalDataSource>(settingsLocal);

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      local: getIt<AuthLocalDataSource>(),
      remote: getIt<AuthRemoteDataSource>(),
    ),
  );

  final tripRepository = TripPlanningRepository();
  await tripRepository.initialize();
  getIt.registerSingleton<TripPlanningRepository>(tripRepository);

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(local: getIt<SettingsLocalDataSource>()),
  );

  getIt.registerLazySingleton<TripExecutionCubit>(
    () => TripExecutionCubit(getIt<TripPlanningRepository>()),
  );
}
