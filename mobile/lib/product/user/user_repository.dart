import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:mobile/product/init/locator.dart';

/// Kullanıcı ve takım işlemleri için repository
final class UserRepository {
  UserRepository(this._dio);

  final Dio _dio;

  /// Kullanıcı listesini döner (paginated veya düz liste ile uyumlu)
  Future<List<Map<String, dynamic>>> listUsers() async {
    di<Logger>().i('[UserRepo] GET users');
    final res = await _dio.get<dynamic>('users/');
    final data = res.data;
    List<dynamic> raw;
    if (data is List) {
      raw = data;
    } else if (data is Map<String, dynamic>) {
      final results = data['results'];
      raw = results is List ? results : const [];
    } else {
      raw = const [];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }

  /// Takım listesini döner (yalnızca aktif veya tüm takımlar backend'e göre gelebilir)
  Future<List<Map<String, dynamic>>> listTeams() async {
    di<Logger>().i('[UserRepo] GET teams');
    final res = await _dio.get<dynamic>('teams/');
    final data = res.data;
    List<dynamic> raw;
    if (data is List) {
      raw = data;
    } else if (data is Map<String, dynamic>) {
      final results = data['results'];
      raw = results is List ? results : const [];
    } else {
      raw = const [];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }

  /// Yeni takım oluşturur
  Future<Map<String, dynamic>> createTeam({
    required String name,
    String? description,
    String? teamType,
    bool? isActive,
  }) async {
    di<Logger>().i('[UserRepo] POST create team name="$name"');
    final res = await _dio.post<Map<String, dynamic>>(
      'teams/',
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (teamType != null) 'team_type': teamType,
        if (isActive != null) 'is_active': isActive,
      },
    );
    return res.data ?? const <String, dynamic>{};
  }

  /// Mevcut takımı günceller (kısmi)
  Future<Map<String, dynamic>> updateTeam(
    int id, {
    String? name,
    String? description,
    String? teamType,
    bool? isActive,
  }) async {
    di<Logger>().i('[UserRepo] PATCH update team id=$id');
    final res = await _dio.patch<Map<String, dynamic>>(
      'teams/$id/',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (teamType != null) 'team_type': teamType,
        if (isActive != null) 'is_active': isActive,
      },
    );
    return res.data ?? const <String, dynamic>{};
  }

  /// Kullanıcı detayını getirir
  Future<Map<String, dynamic>> fetchUserDetail(int id) async {
    di<Logger>().i('[UserRepo] GET user detail id=$id');
    final res = await _dio.get<Map<String, dynamic>>('users/$id/');
    return res.data ?? const <String, dynamic>{};
  }

  /// Yeni kullanıcı oluşturur
  Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    String? username,
    String? firstName,
    String? lastName,
    String? role,
    int? teamId,
    String? phone,
    String? address,
  }) async {
    di<Logger>().i('[UserRepo] POST create user email="$email"');
    final res = await _dio.post<Map<String, dynamic>>(
      'users/',
      data: {
        'email': email,
        'password': password,
        if (username != null) 'username': username,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (role != null) 'role': role,
        if (teamId != null) 'team': teamId,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      },
    );
    return res.data ?? const <String, dynamic>{};
  }

  /// Kullanıcı bilgilerini günceller
  Future<Map<String, dynamic>> updateUser(
    int id, {
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? role,
    int? teamId,
    String? phone,
    String? address,
    bool? isActive,
  }) async {
    di<Logger>().i('[UserRepo] PATCH update user id=$id');
    final res = await _dio.patch<Map<String, dynamic>>(
      'users/$id/',
      data: {
        if (email != null) 'email': email,
        if (username != null) 'username': username,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (role != null) 'role': role,
        if (teamId != null) 'team': teamId,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (isActive != null) 'is_active': isActive,
      },
    );
    return res.data ?? const <String, dynamic>{};
  }

  /// Kullanıcıyı siler
  Future<void> deleteUser(int id) async {
    di<Logger>().i('[UserRepo] DELETE user id=$id');
    await _dio.delete('users/$id/');
  }

  /// Kullanıcının şifresini değiştirir
  Future<void> changeUserPassword(int id, String newPassword) async {
    di<Logger>().i('[UserRepo] POST change password for user id=$id');
    await _dio.post(
      'users/$id/change-password/',
      data: {'new_password': newPassword},
    );
  }
}