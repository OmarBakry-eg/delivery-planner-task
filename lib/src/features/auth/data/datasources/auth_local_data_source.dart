import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:test_hsa_group/src/features/auth/data/models/auth_user_model.dart';

class AuthLocalDataSource {
  static const String _boxName = 'auth_box';
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  Box? _box;

  Future<void> initialize() async {
    _box = Hive.isBoxOpen(_boxName)
        ? Hive.box(_boxName)
        : await Hive.openBox(_boxName);
  }

  Future<void> saveSession({
    required String token,
    required AuthUserModel user,
  }) async {
    await _ensure();
    await _box!.put(_tokenKey, token);
    await _box!.put(_userKey, user.toJson());
  }

  Future<String?> getToken() async {
    await _ensure();
    return _box!.get(_tokenKey) as String?;
  }

  Future<AuthUserModel?> getUser() async {
    await _ensure();
    final json = _box!.get(_userKey);
    if (json is Map) {
      return AuthUserModel.fromJson(Map<String, dynamic>.from(json));
    }
    return null;
  }

  Future<void> clear() async {
    await _ensure();
    await _box!.delete(_tokenKey);
    await _box!.delete(_userKey);
  }

  Future<void> _ensure() async {
    if (_box == null || !_box!.isOpen) {
      await initialize();
    }
  }
}
