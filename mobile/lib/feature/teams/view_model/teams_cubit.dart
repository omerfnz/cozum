import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/user.dart' show Team, TeamType;
import '../../../product/service/network/network_service.dart';
import '../../../product/service/auth/auth_service.dart';
import 'teams_state.dart';

class TeamsCubit extends Cubit<TeamsState> {
  TeamsCubit() : super(const TeamsInitial()) {
    _networkService = GetIt.I<INetworkService>();
    _authService = GetIt.I<IAuthService>();
  }

  late final INetworkService _networkService;
  late final IAuthService _authService;

  /// Ekipleri ve kullanıcı rolünü yükler
  Future<void> loadTeams() async {
    try {
      emit(const TeamsLoading());
      
      // Kullanıcı rolünü yükle
      String userRole = 'VATANDAS';
      try {
        final me = await _authService.getCurrentUser();
        userRole = me.data?.role ?? 'VATANDAS';
      } catch (_) {
        // Rol yüklenemezse varsayılan rol kullan
      }
      
      // Ekipleri yükle
      final res = await _networkService.request<List<Team>>(
        path: ApiEndpoints.teams,
        type: RequestType.get,
        parser: (json) {
          if (json is List) {
            return json.map((e) => Team.fromJson(e as Map<String, dynamic>)).toList();
          }
          if (json is Map && json['results'] is List) {
            return (json['results'] as List)
                .map((e) => Team.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <Team>[];
        },
      );
      
      if (res.isSuccess) {
        emit(TeamsLoaded(
          teams: res.data ?? [],
          userRole: userRole,
        ));
      } else {
        emit(TeamsError(res.error ?? 'Ekipler yüklenemedi'));
      }
    } catch (e) {
      emit(TeamsError('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Yeni ekip oluşturur
  Future<void> createTeam({
    required String name,
    String? description,
    required TeamType teamType,
    required bool isActive,
  }) async {
    // Validasyon
    if (name.trim().isEmpty) {
      emit(const TeamValidationError(nameError: 'Ad zorunludur'));
      return;
    }

    try {
      emit(const TeamOperationLoading());
      
      final body = <String, dynamic>{
        'name': name.trim(),
        if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
        'team_type': teamType.value,
        'is_active': isActive,
      };
      
      final res = await _networkService.request<Team>(
        path: ApiEndpoints.teams,
        type: RequestType.post,
        data: body,
        parser: (json) => Team.fromJson(json as Map<String, dynamic>),
      );
      
      if (res.isSuccess) {
        emit(const TeamOperationSuccess('Ekip oluşturuldu'));
        // Listeyi yeniden yükle
        await loadTeams();
      } else {
        emit(TeamOperationFailure(res.error ?? 'Ekip oluşturulamadı'));
      }
    } catch (e) {
      emit(TeamOperationFailure('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Ekibi günceller
  Future<void> updateTeam({
    required int teamId,
    required String name,
    String? description,
    required TeamType teamType,
    required bool isActive,
  }) async {
    // Validasyon
    if (name.trim().isEmpty) {
      emit(const TeamValidationError(nameError: 'Ad zorunludur'));
      return;
    }

    try {
      emit(const TeamOperationLoading());
      
      final body = <String, dynamic>{
        'name': name.trim(),
        if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
        'team_type': teamType.value,
        'is_active': isActive,
      };
      
      final res = await _networkService.request<Team>(
        path: ApiEndpoints.teamById(teamId),
        type: RequestType.patch,
        data: body,
        parser: (json) => Team.fromJson(json as Map<String, dynamic>),
      );
      
      if (res.isSuccess) {
        emit(const TeamOperationSuccess('Ekip güncellendi'));
        // Listeyi yeniden yükle
        await loadTeams();
      } else {
        emit(TeamOperationFailure(res.error ?? 'Ekip güncellenemedi'));
      }
    } catch (e) {
      emit(TeamOperationFailure('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Ekibi siler
  Future<void> deleteTeam(int teamId) async {
    try {
      emit(const TeamOperationLoading());
      
      final res = await _networkService.request<dynamic>(
        path: ApiEndpoints.teamById(teamId),
        type: RequestType.delete,
      );
      
      if (res.isSuccess) {
        emit(const TeamOperationSuccess('Ekip silindi'));
        // Listeyi yeniden yükle
        await loadTeams();
      } else {
        emit(TeamOperationFailure(res.error ?? 'Ekip silinemedi'));
      }
    } catch (e) {
      emit(TeamOperationFailure('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Ekibe üye ekler
  Future<void> addMemberToTeam(int teamId, int userId) async {
    try {
      emit(const TeamOperationLoading());
      
      final res = await _networkService.request<dynamic>(
        path: ApiEndpoints.userSetTeam(userId),
        type: RequestType.post,
        data: {
          'team_id': teamId,
        },
      );
      
      if (res.isSuccess) {
        emit(const TeamOperationSuccess('Üye eklendi'));
        // Listeyi yeniden yükle (üye sayısı güncellensin)
        await loadTeams();
      } else {
        emit(TeamOperationFailure(res.error ?? 'Üye eklenemedi'));
      }
    } catch (e) {
      emit(TeamOperationFailure('Beklenmeyen bir hata oluştu: $e'));
    }
  }

  /// Ekip adı doğrulama
  String? validateTeamName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Ad zorunludur';
    }
    return null;
  }

  /// Durumu sıfırlar
  void resetState() {
    emit(const TeamsInitial());
  }

  /// Mevcut kullanıcının yönetim yetkisi var mı?
  bool get canManage {
    final currentState = state;
    if (currentState is TeamsLoaded) {
      final role = currentState.userRole;
      return role == 'OPERATOR' || role == 'ADMIN';
    }
    return false;
  }
}