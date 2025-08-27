import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/init/service_locator.dart';
import '../../../product/service/auth/auth_service.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginInitial());

  final IAuthService _authService = serviceLocator<IAuthService>();

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-posta gerekli';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Geçerli bir e-posta giriniz';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Şifre gerekli';
    if (value.length < 6) return 'Şifre en az 6 karakter olmalı';
    return null;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Validation
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (emailError != null || passwordError != null) {
      emit(LoginValidationError(
        emailError: emailError,
        passwordError: passwordError,
      ));
      return;
    }

    emit(const LoginLoading());

    try {
      final result = await _authService.login(
        email: email.trim(),
        password: password,
      );

      if (result.isSuccess) {
        emit(const LoginSuccess());
      } else {
        emit(LoginFailure(result.error ?? 'Giriş başarısız'));
      }
    } catch (e) {
      emit(LoginFailure('Bir hata oluştu: $e'));
    }
  }

  void resetState() {
    emit(const LoginInitial());
  }
}