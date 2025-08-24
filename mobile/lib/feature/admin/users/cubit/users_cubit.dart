import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:mobile/feature/admin/users/cubit/users_state.dart';
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/report/model/report_models.dart';
import 'package:mobile/product/user/user_repository.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(const UsersState());

  final _repository = di<UserRepository>();
  final _logger = di<Logger>();

  /// Kullanıcıları yükler
  Future<void> fetchUsers() async {
    if (state.isLoading) return;
    
    emit(state.copyWith(
      isLoading: true,
      error: null,
    ));
    
    try {
      _logger.i('[UsersCubit] Fetching users');
      final usersData = await _repository.listUsers();
      
      final users = usersData
          .map((data) => UserDto.fromJson(data))
          .toList();
      
      emit(state.copyWith(
        users: users,
        isLoading: false,
        error: null,
      ));
      
      _logger.i('[UsersCubit] Users loaded: ${users.length}');
    } catch (e, stackTrace) {
      _logger.e('[UsersCubit] Error fetching users: $e', stackTrace: stackTrace);
      emit(state.copyWith(
        isLoading: false,
        error: 'Kullanıcılar yüklenirken hata oluştu: $e',
      ));
    }
  }

  /// Kullanıcıları yeniler
  Future<void> refreshUsers() async {
    await fetchUsers();
  }

  /// Yeni kullanıcı oluşturur
  Future<bool> createUser({
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
    if (state.isLoading) return false;
    
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      _logger.i('[UsersCubit] Creating user: $email');
      final userData = await _repository.createUser(
        email: email,
        password: password,
        username: username,
        firstName: firstName,
        lastName: lastName,
        role: role,
        teamId: teamId,
        phone: phone,
        address: address,
      );
      
      final newUser = UserDto.fromJson(userData);
      
      emit(state.copyWith(
        users: [...state.users, newUser],
        isLoading: false,
        error: null,
      ));
      
      _logger.i('[UsersCubit] User created successfully: ${newUser.id}');
      return true;
    } catch (e, stackTrace) {
      _logger.e('[UsersCubit] Error creating user: $e', stackTrace: stackTrace);
      emit(state.copyWith(
        isLoading: false,
        error: 'Kullanıcı oluşturulurken hata oluştu: $e',
      ));
      return false;
    }
  }

  /// Kullanıcı bilgilerini günceller
  Future<bool> updateUser({
    required int id,
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
    if (state.isLoading) return false;
    
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      _logger.i('[UsersCubit] Updating user: $id');
      final userData = await _repository.updateUser(
        id,
        email: email,
        username: username,
        firstName: firstName,
        lastName: lastName,
        role: role,
        teamId: teamId,
        phone: phone,
        address: address,
        isActive: isActive,
      );
      
      final updatedUser = UserDto.fromJson(userData);
      
      final updatedUsers = state.users.map((user) {
        return user.id == id ? updatedUser : user;
      }).toList();
      
      emit(state.copyWith(
        users: updatedUsers,
        isLoading: false,
        error: null,
      ));
      
      _logger.i('[UsersCubit] User updated successfully: $id');
      return true;
    } catch (e, stackTrace) {
      _logger.e('[UsersCubit] Error updating user: $e', stackTrace: stackTrace);
      emit(state.copyWith(
        isLoading: false,
        error: 'Kullanıcı güncellenirken hata oluştu: $e',
      ));
      return false;
    }
  }

  /// Kullanıcıyı siler
  Future<bool> deleteUser(int id) async {
    if (state.isLoading) return false;
    
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      _logger.i('[UsersCubit] Deleting user: $id');
      await _repository.deleteUser(id);
      
      final updatedUsers = state.users.where((user) => user.id != id).toList();
      
      emit(state.copyWith(
        users: updatedUsers,
        isLoading: false,
        error: null,
      ));
      
      _logger.i('[UsersCubit] User deleted successfully: $id');
      return true;
    } catch (e, stackTrace) {
      _logger.e('[UsersCubit] Error deleting user: $e', stackTrace: stackTrace);
      emit(state.copyWith(
        isLoading: false,
        error: 'Kullanıcı silinirken hata oluştu: $e',
      ));
      return false;
    }
  }

  /// Kullanıcının şifresini değiştirir
  Future<bool> changeUserPassword(int id, String newPassword) async {
    if (state.isLoading) return false;
    
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      _logger.i('[UsersCubit] Changing password for user: $id');
      await _repository.changeUserPassword(id, newPassword);
      
      emit(state.copyWith(
        isLoading: false,
        error: null,
      ));
      
      _logger.i('[UsersCubit] Password changed successfully for user: $id');
      return true;
    } catch (e, stackTrace) {
      _logger.e('[UsersCubit] Error changing password: $e', stackTrace: stackTrace);
      emit(state.copyWith(
        isLoading: false,
        error: 'Şifre değiştirilirken hata oluştu: $e',
      ));
      return false;
    }
  }

  /// Hata mesajını temizler
  void clearError() {
    if (state.hasError) {
      emit(state.copyWith(error: null));
    }
  }
}