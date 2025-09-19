import 'package:test_hsa_group/src/features/auth/domain/entities/auth_user.dart';
import 'package:test_hsa_group/src/features/auth/domain/repositories/auth_repository.dart';

class GetAuthStatusUseCase {
  final AuthRepository repository;
  const GetAuthStatusUseCase(this.repository);

  Future<(bool isAuthenticated, AuthUser? user)> call() async {
    final authed = await repository.isAuthenticated();
    final user = authed ? await repository.getCurrentUser() : null;
    return (authed, user);
  }
}
