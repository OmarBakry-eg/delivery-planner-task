import 'package:test_hsa_group/src/core/config/app_config.dart';
import 'package:test_hsa_group/src/features/settings/domain/repositories/settings_repository.dart';

class SetEnvironment {
  final SettingsRepository repository;
  const SetEnvironment(this.repository);

  Future<void> call(BuildFlavor flavor) => repository.setEnvironment(flavor);
}


