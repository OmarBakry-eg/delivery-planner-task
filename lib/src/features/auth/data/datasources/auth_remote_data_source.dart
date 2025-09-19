import 'dart:async';
import 'package:test_hsa_group/src/features/auth/data/models/auth_user_model.dart';

class AuthRemoteDataSource {
  Future<(String token, AuthUserModel user)> authenticate({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    const validEmail = 'dispatcher@demo.com';
    const validPassword = 'password123';

    if (email.trim().toLowerCase() == validEmail && password == validPassword) {
      return (
        'demo-token-123',
        AuthUserModel(id: 'u01', name: 'Dispatcher Demo', email: validEmail),
      );
    }

    throw Exception('Invalid credentials');
  }
}
