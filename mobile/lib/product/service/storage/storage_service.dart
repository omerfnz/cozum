import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage service interface
abstract class IStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> clear();
  Future<bool> containsKey(String key);
  
  // Token management methods
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<void> clearTokens();
}

/// Secure storage service implementation
final class StorageService implements IStorageService {
  StorageService(this._secureStorage);
  
  final FlutterSecureStorage _secureStorage;
  
  // In-memory cache to avoid repeated secure storage hits
  String? _accessTokenCache;
  String? _refreshTokenCache;
  
  @override
  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }
  
  @override
  Future<String?> read(String key) async {
    return await _secureStorage.read(key: key);
  }
  
  @override
  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }
  
  @override
  Future<void> clear() async {
    await _secureStorage.deleteAll();
  }
  
  @override
  Future<bool> containsKey(String key) async {
    return await _secureStorage.containsKey(key: key);
  }
  
  @override
  Future<String?> getAccessToken() async {
    if (_accessTokenCache != null) return _accessTokenCache;
    final token = await read(StorageKeys.accessToken);
    _accessTokenCache = token;
    return token;
  }
  
  @override
  Future<String?> getRefreshToken() async {
    if (_refreshTokenCache != null) return _refreshTokenCache;
    final token = await read(StorageKeys.refreshToken);
    _refreshTokenCache = token;
    return token;
  }
  
  @override
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    // Update cache first
    _accessTokenCache = accessToken;
    if (refreshToken != null) {
      _refreshTokenCache = refreshToken;
    }
    // Persist to secure storage
    await write(StorageKeys.accessToken, accessToken);
    if (refreshToken != null) {
      await write(StorageKeys.refreshToken, refreshToken);
    }
  }
  
  @override
  Future<void> clearTokens() async {
    // Clear cache
    _accessTokenCache = null;
    _refreshTokenCache = null;
    // Remove from storage
    await delete(StorageKeys.accessToken);
    await delete(StorageKeys.refreshToken);
  }
}

/// Storage keys constants
final class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userProfile = 'user_profile';
  static const String appTheme = 'app_theme';
  static const String appLanguage = 'app_language';
}