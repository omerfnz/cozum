import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  const RegisterSuccess();
}

class RegisterFailure extends RegisterState {
  final String message;

  const RegisterFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class RegisterValidationError extends RegisterState {
  final String? emailError;
  final String? usernameError;
  final String? passwordError;
  final String? confirmPasswordError;

  const RegisterValidationError({
    this.emailError,
    this.usernameError,
    this.passwordError,
    this.confirmPasswordError,
  });

  @override
  List<Object?> get props => [emailError, usernameError, passwordError, confirmPasswordError];
}