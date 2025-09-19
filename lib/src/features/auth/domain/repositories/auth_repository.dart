import 'package:test_hsa_group/src/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<AuthUser> login({required String email, required String password});
  Future<void> logout();
}
