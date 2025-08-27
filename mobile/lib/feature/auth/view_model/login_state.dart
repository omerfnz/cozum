import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess();
}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class LoginValidationError extends LoginState {
  final String? emailError;
  final String? passwordError;

  const LoginValidationError({
    this.emailError,
    this.passwordError,
  });

  @override
  List<Object?> get props => [emailError, passwordError];
}