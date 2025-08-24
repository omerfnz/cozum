import 'package:dio/dio.dart';
import 'package:mobile/product/report/model/report_models.dart';

class TeamRepository {
  final Dio _dio;

  TeamRepository(this._dio);

  Future<List<TeamDto>> getTeams({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final response = await _dio.get(
        '/teams/',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      final List<dynamic> data = response.data['results'] ?? [];
      return data.map((json) => TeamDto.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch teams: $e');
    }
  }

  Future<TeamDto> createTeam({
    required String name,
    required String description,
    required String teamType,
    bool isActive = true,
  }) async {
    try {
      final response = await _dio.post(
        '/teams/',
        data: {
          'name': name,
          'description': description,
          'team_type': teamType,
          'is_active': isActive,
        },
      );

      return TeamDto.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create team: $e');
    }
  }

  Future<TeamDto> updateTeam({
    required int id,
    required String name,
    required String description,
    required String teamType,
    required bool isActive,
  }) async {
    try {
      final response = await _dio.put(
        '/teams/$id/',
        data: {
          'name': name,
          'description': description,
          'team_type': teamType,
          'is_active': isActive,
        },
      );

      return TeamDto.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update team: $e');
    }
  }

  Future<void> deleteTeam(int id) async {
    try {
      await _dio.delete('/teams/$id/');
    } catch (e) {
      throw Exception('Failed to delete team: $e');
    }
  }

  Future<TeamDto> getTeam(int id) async {
    try {
      final response = await _dio.get('/teams/$id/');
      return TeamDto.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch team: $e');
    }
  }
}