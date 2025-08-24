import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/report/model/report_models.dart';

/// Takım (Team) işlemleri için repository
final class TeamRepository {
  TeamRepository(this._dio);

  final Dio _dio;

  /// Takım listesini getirir
  Future<List<TeamDto>> fetchTeams() async {
    di<Logger>().i('[TeamRepo] GET teams');
    final res = await _dio.get<dynamic>('teams/');
    final data = res.data;
    List<dynamic> raw = const [];
    if (data is List) {
      raw = data;
    } else if (data is Map<String, dynamic>) {
      if (data['results'] is List) raw = data['results'] as List;
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map((e) => TeamDto.fromJson(e))
        .toList(growable: false);
  }

  /// Tekil takım detayını getirir
  Future<TeamDto> fetchTeamDetail(int id) async {
    di<Logger>().i('[TeamRepo] GET team detail id=$id');
    final res = await _dio.get<Map<String, dynamic>>('teams/$id/');
    final data = res.data ?? const <String, dynamic>{};
    return TeamDto.fromJson(data);
  }

  /// Yeni takım oluşturur
  Future<TeamDto> createTeam({
    required String name,
    String? description,
    String? teamType,
  }) async {
    di<Logger>().i('[TeamRepo] POST create team: name="$name"');
    final res = await _dio.post<Map<String, dynamic>>(
      'teams/',
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (teamType != null) 'team_type': teamType,
      },
    );
    final data = res.data ?? const <String, dynamic>{};
    return TeamDto.fromJson(data);
  }

  /// Takım bilgilerini günceller
  Future<TeamDto> updateTeam({
    required int id,
    String? name,
    String? description,
    String? teamType,
    bool? isActive,
  }) async {
    di<Logger>().i('[TeamRepo] PATCH update team id=$id');
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (description != null) payload['description'] = description;
    if (teamType != null) payload['team_type'] = teamType;
    if (isActive != null) payload['is_active'] = isActive;
    
    final res = await _dio.patch<Map<String, dynamic>>(
      'teams/$id/',
      data: payload,
    );
    final data = res.data ?? const <String, dynamic>{};
    return TeamDto.fromJson(data);
  }

  /// Takımı siler
  Future<void> deleteTeam(int id) async {
    di<Logger>().i('[TeamRepo] DELETE team id=$id');
    await _dio.delete<void>('teams/$id/');
  }

  /// Takım üyelerini getirir
  Future<List<UserDto>> fetchTeamMembers(int teamId) async {
    di<Logger>().i('[TeamRepo] GET team members teamId=$teamId');
    final res = await _dio.get<dynamic>('teams/$teamId/members/');
    final data = res.data;
    List<dynamic> raw = const [];
    if (data is List) {
      raw = data;
    } else if (data is Map<String, dynamic>) {
      if (data['results'] is List) raw = data['results'] as List;
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map((e) => UserDto.fromJson(e))
        .toList(growable: false);
  }

  /// Takıma üye ekler
  Future<void> addMemberToTeam({
    required int teamId,
    required int userId,
  }) async {
    di<Logger>().i('[TeamRepo] POST add member teamId=$teamId userId=$userId');
    await _dio.post<void>(
      'teams/$teamId/members/',
      data: {'user_id': userId},
    );
  }

  /// Takımdan üye çıkarır
  Future<void> removeMemberFromTeam({
    required int teamId,
    required int userId,
  }) async {
    di<Logger>().i('[TeamRepo] DELETE remove member teamId=$teamId userId=$userId');
    await _dio.delete<void>('teams/$teamId/members/$userId/');
  }
}