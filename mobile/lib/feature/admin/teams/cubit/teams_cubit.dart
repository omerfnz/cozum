import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/report/model/report_models.dart';
import 'package:mobile/product/team/team_repository.dart';

part 'teams_state.dart';

/// Takımlar listesi için Cubit
class TeamsCubit extends Cubit<TeamsState> {
  TeamsCubit() : super(const TeamsState());

  final _repository = di<TeamRepository>();
  final _logger = di<Logger>();

  /// Takımları yükler
  Future<void> fetchTeams() async {
    if (state.isLoading) return;
    
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      _logger.i('[TeamsCubit] Fetching teams');
      final teams = await _repository.fetchTeams();
      
      emit(state.copyWith(
        isLoading: false,
        teams: teams,
        error: null,
      ));
      
      _logger.i('[TeamsCubit] Teams loaded: ${teams.length}');
    } catch (e, stackTrace) {
      _logger.e('[TeamsCubit] Error fetching teams: $e', stackTrace: stackTrace);
      emit(state.copyWith(
        isLoading: false,
        error: 'Takımlar yüklenirken hata oluştu: $e',
      ));
    }
  }

  /// Takımları yeniler (refresh)
  Future<void> refreshTeams() async {
    emit(state.copyWith(teams: [], error: null));
    await fetchTeams();
  }

  /// Yeni takım oluşturur
  Future<bool> createTeam({
    required String name,
    String? description,
    String? teamType,
  }) async {
    if (state.isLoading) return false;
    
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      _logger.i('[TeamsCubit] Creating team: $name');
      final newTeam = await _repository.createTeam(
        name: name,
        description: description,
        teamType: teamType,
      );
      
      final updatedTeams = [newTeam, ...state.teams];
      emit(state.copyWith(
        isLoading: false,
        teams: updatedTeams,
        error: null,
      ));
      
      _logger.i('[TeamsCubit] Team created successfully: ${newTeam.id}');
      return true;
    } catch (e, stackTrace) {
      _logger.e('[TeamsCubit] Error creating team: $e', stackTrace: stackTrace);
      emit(state.copyWith(
        isLoading: false,
        error: 'Takım oluşturulurken hata oluştu: $e',
      ));
      return false;
    }
  }

  /// Takım günceller
  Future<bool> updateTeam({
    required int id,
    String? name,
    String? description,
    String? teamType,
    bool? isActive,
  }) async {
    if (state.isLoading) return false;
    
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      _logger.i('[TeamsCubit] Updating team: $id');
      final updatedTeam = await _repository.updateTeam(
        id: id,
        name: name,
        description: description,
        teamType: teamType,
        isActive: isActive,
      );
      
      final updatedTeams = state.teams.map((team) {
        return team.id == id ? updatedTeam : team;
      }).toList();
      
      emit(state.copyWith(
        isLoading: false,
        teams: updatedTeams,
        error: null,
      ));
      
      _logger.i('[TeamsCubit] Team updated successfully: $id');
      return true;
    } catch (e, stackTrace) {
      _logger.e('[TeamsCubit] Error updating team: $e', stackTrace: stackTrace);
      emit(state.copyWith(
        isLoading: false,
        error: 'Takım güncellenirken hata oluştu: $e',
      ));
      return false;
    }
  }

  /// Takım siler
  Future<bool> deleteTeam(int id) async {
    if (state.isLoading) return false;
    
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      _logger.i('[TeamsCubit] Deleting team: $id');
      await _repository.deleteTeam(id);
      
      final updatedTeams = state.teams.where((team) => team.id != id).toList();
      emit(state.copyWith(
        isLoading: false,
        teams: updatedTeams,
        error: null,
      ));
      
      _logger.i('[TeamsCubit] Team deleted successfully: $id');
      return true;
    } catch (e, stackTrace) {
      _logger.e('[TeamsCubit] Error deleting team: $e', stackTrace: stackTrace);
      emit(state.copyWith(
        isLoading: false,
        error: 'Takım silinirken hata oluştu: $e',
      ));
      return false;
    }
  }

  /// Hata mesajını temizler
  void clearError() {
    if (state.error != null) {
      emit(state.copyWith(error: null));
    }
  }
}