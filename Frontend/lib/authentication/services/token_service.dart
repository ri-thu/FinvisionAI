import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  // Remove _accessTokenKey as we won't store it persistently
  static const _refreshTokenKey = 'refresh_token';
  static const _persistLoginKey = 'persist_login';

  final FlutterSecureStorage _secureStorage;

  TokenService(this._secureStorage);

  // Remove access token persistence methods as we'll keep it in state

  // Refresh Token methods
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // Clear tokens on logout
  Future<void> clearTokens() async {
    // Only need to clear refresh token now
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  // Persist login preference
  Future<void> setPersistLogin(bool persist) async {
    await _secureStorage.write(
      key: _persistLoginKey,
      value: persist.toString(),
    );
  }

  Future<bool> getPersistLogin() async {
    final value = await _secureStorage.read(key: _persistLoginKey);
    return value == 'true';
  }
}
