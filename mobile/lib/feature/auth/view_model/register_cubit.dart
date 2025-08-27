import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/init/service_locator.dart';
import '../../../product/service/auth/auth_service.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterInitial());

  final IAuthService _authService = serviceLocator<IAuthService>();

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-posta gerekli';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Geçerli bir e-posta giriniz';
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Kullanıcı adı gerekli';
    if (value.length < 3) return 'En az 3 karakter olmalı';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Şifre gerekli';
    if (value.length < 6) return 'Şifre en az 6 karakter olmalı';
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Şifre tekrarı gerekli';
    if (value != password) return 'Şifreler eşleşmiyor';
    return null;
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    // Validation
    final emailError = validateEmail(email);
    final usernameError = validateUsername(username);
    final passwordError = validatePassword(password);
    final confirmPasswordError = validateConfirmPassword(confirmPassword, password);

    if (emailError != null || usernameError != null || passwordError != null || confirmPasswordError != null) {
      emit(RegisterValidationError(
        emailError: emailError,
        usernameError: usernameError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
      ));
      return;
    }

    emit(const RegisterLoading());

    try {
      final result = await _authService.register(
        email: email.trim(),
        username: username.trim(),
        password: password,
      );

      if (result.isSuccess) {
        emit(const RegisterSuccess());
      } else {
        emit(RegisterFailure(result.error ?? 'Kayıt başarısız'));
      }
    } catch (e) {
      emit(RegisterFailure('Bir hata oluştu: $e'));
    }
  }

  void resetState() {
    emit(const RegisterInitial());
  }
}