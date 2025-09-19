import 'package:test_hsa_group/src/features/auth/domain/entities/auth_user.dart';
import 'package:test_hsa_group/src/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<AuthUser> call(String email, String password) {
    return repository.login(email: email, password: password);
  }
}
