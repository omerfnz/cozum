import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:mobile/product/auth/token_storage.dart';
import 'package:mobile/product/init/locator.dart';

/// Kimlik doğrulama işlemlerini yöneten repository
final class AuthRepository {
  /// Dio istemcisi ve güvenli depolama bağımlılıkları ile kurulur.
  AuthRepository(this._dio, this._storage);

  final Dio _dio;
  final TokenStorage _storage;

  /// E-posta ve şifre ile giriş yapar, access ve refresh tokenları güvenli şekilde saklar.
  Future<void> login({required String email, required String password}) async {
    di<Logger>().i('[Auth] POST login <$email>');
    final res = await _dio.post<Map<String, dynamic>>(
      'auth/login/',
      data: {'email': email, 'password': password},
    );
    final data = res.data ?? const <String, dynamic>{};
    final access = data['access'] as String?;
    final refresh = data['refresh'] as String?;
    if (access == null || refresh == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: 'Geçersiz yanıt: access/refresh yok',
      );
    }
    await _storage.writeAccessToken(access);
    await _storage.writeRefreshToken(refresh);
    di<Logger>().i('[Auth] Login başarılı, tokenlar kaydedildi');
  }

  /// Yeni kullanıcı kaydı oluşturur.
  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String passwordConfirm,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
  }) async {
    final payload = <String, dynamic>{
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'password_confirm': passwordConfirm,
      'role': 'VATANDAS',
      'phone': phone,
      'address': address,
    }..removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    di<Logger>().i('[Auth] POST register <$email>');
    await _dio.post<void>('auth/register/', data: payload);
    di<Logger>().i('[Auth] Register başarılı');
  }

  /// Kimlik doğrulanmış kullanıcının profil bilgilerini döner.
  Future<Map<String, dynamic>?> me() async {
    di<Logger>().i('[Auth] GET me');
    final res = await _dio.get<Map<String, dynamic>>('auth/me/');
    return res.data;
  }

  /// Refresh token ile access tokenı yeniler.
  Future<bool> refresh() async {
    final refresh = await _storage.readRefreshToken();
    if (refresh == null) return false;
    di<Logger>().i('[Auth] POST refresh');
    final res = await _dio.post<Map<String, dynamic>>(
      'auth/refresh/',
      data: {'refresh': refresh},
    );
    final data = res.data ?? const <String, dynamic>{};
    final access = data['access'] as String?;
    if (access == null) return false;
    await _storage.writeAccessToken(access);
    di<Logger>().i('[Auth] Refresh başarılı');
    return true;
  }

  /// Çıkış yapar: backend'e haber verir ve tüm saklı tokenları temizler.
  Future<void> logout() async {
    di<Logger>().i('[Auth] POST logout');
    try {
      await _dio.post<void>('auth/logout/');
      di<Logger>().i('[Auth] Logout endpoint çağrısı tamamlandı');
    } catch (e, st) {
      // Backend logout endpoint'i opsiyonel olabilir; hata olsa dahi tokenları temizlemeye devam ediyoruz.
      di<Logger>().w('[Auth] Logout endpoint hatası, token temizlemeye devam', error: e, stackTrace: st);
    } finally {
      di<Logger>().i('[Auth] Logout, tokenlar temizleniyor');
      await _storage.clear();
    }
  }

  /// Kullanıcının şifresini değiştirir.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    di<Logger>().i('[Auth] PATCH change password');
    await _dio.patch<void>(
      'auth/password/change/',
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirm': newPasswordConfirm,
      },
    );
    di<Logger>().i('[Auth] Şifre değiştirildi');
  }
}
