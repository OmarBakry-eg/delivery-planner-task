import 'package:test_hsa_group/src/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:test_hsa_group/src/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:test_hsa_group/src/features/auth/domain/entities/auth_user.dart';
import 'package:test_hsa_group/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource local;
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl({required this.local, required this.remote});

  @override
  Future<AuthUser?> getCurrentUser() async {
    await local.initialize();
    return await local.getUser();
  }

  @override
  Future<bool> isAuthenticated() async {
    await local.initialize();
    final token = await local.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final (token, user) = await remote.authenticate(
      email: email,
      password: password,
    );
    await local.saveSession(token: token, user: user);
    return user;
  }

  @override
  Future<void> logout() async {
    await local.clear();
  }
}
