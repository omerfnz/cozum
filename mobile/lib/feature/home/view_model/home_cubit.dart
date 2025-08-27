import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../product/service/auth/auth_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeInitial()) {
    _authService = GetIt.I<IAuthService>();
  }

  late final IAuthService _authService;

  /// Kullanıcı bilgilerini yükler
  Future<void> loadUser() async {
    try {
      emit(const HomeLoading());
      
      final me = await _authService
          .getCurrentUser()
          .timeout(const Duration(seconds: 12));
      
      final userRole = me.data?.role ?? 'VATANDAS';
      
      emit(HomeLoaded(
        userRole: userRole,
        currentTabIndex: 0,
      ));
    } on TimeoutException {
      // Timeout durumunda varsayılan rol ile devam et
      emit(const HomeLoaded(
        userRole: 'VATANDAS',
        currentTabIndex: 0,
      ));
    } catch (e) {
      // Hata durumunda varsayılan rol ile devam et
      emit(const HomeLoaded(
        userRole: 'VATANDAS',
        currentTabIndex: 0,
      ));
    }
  }

  /// Tab değiştirir
  void changeTab(int index) {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(currentState.copyWith(currentTabIndex: index));
    }
  }

  /// Kullanıcı çıkışı yapar
  Future<void> logout() async {
    try {
      emit(const HomeLogoutLoading());
      
      await _authService.logout();
      
      // UI'nin güncellenmesi için kısa bir bekleme
      await Future.delayed(const Duration(milliseconds: 100));
      
      emit(const HomeLogoutSuccess());
    } catch (e) {
      // Hata durumunda da çıkış başarılı sayılır
      emit(const HomeLogoutSuccess());
    }
  }

  /// Durumu sıfırlar
  void resetState() {
    emit(const HomeInitial());
  }

  /// Mevcut kullanıcı rolünü döndürür
  String get currentUserRole {
    final currentState = state;
    if (currentState is HomeLoaded) {
      return currentState.userRole;
    }
    return 'VATANDAS';
  }

  /// Mevcut tab index'ini döndürür
  int get currentTabIndex {
    final currentState = state;
    if (currentState is HomeLoaded) {
      return currentState.currentTabIndex;
    }
    return 0;
  }
}