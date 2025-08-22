import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Erişim ve yenileme tokenlarını güvenli şekilde saklayan sınıf
final class TokenStorage {
  /// [TokenStorage] için opsiyonel özel [FlutterSecureStorage] örneği alır.
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  /// Güvenli depodan erişim (access) tokenını okur.
  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  /// Erişim (access) tokenını güvenli depoya yazar.
  Future<void> writeAccessToken(String token) =>
      _storage.write(key: _accessKey, value: token);

  /// Güvenli depodan yenileme (refresh) tokenını okur.
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  /// Yenileme (refresh) tokenını güvenli depoya yazar.
  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: _refreshKey, value: token);

  /// Tüm saklanan kimlik doğrulama tokenlarını temizler.
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
