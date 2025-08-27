import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/navigation/app_router.dart';
import '../../../product/service/auth/auth_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._auth) : super(const ProfileInitial());

  final IAuthService _auth;

  Future<void> load() async {
    emit(const ProfileLoading());
    try {
      final res = await _auth.getCurrentUser();
      if (res.isSuccess && res.data != null) {
        emit(ProfileLoaded(res.data!));
      } else {
        emit(ProfileError(res.error ?? 'Profil bilgisi yüklenemedi.'));
      }
    } catch (e) {
      emit(ProfileError('Profil yüklenirken hata oluştu: $e'));
    }
  }

  Future<void> logout(StackRouter router) async {
    try {
      await _auth.logout();
      // UI'nin güncellenmesi için kısa bir bekleme
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (_) {}
    router.replaceAll([const LoginViewRoute()]);
  }
}