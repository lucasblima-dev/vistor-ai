import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vistor_ai_mobile/shared/models/user.dart';

class TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'cached_user';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveUser(User user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: jsonStr);
  }

  Future<User?> getUser() async {
    final jsonStr = await _storage.read(key: _userKey);
    if (jsonStr == null) return null;
    try {
      return User.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return null;
    }
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }
}
