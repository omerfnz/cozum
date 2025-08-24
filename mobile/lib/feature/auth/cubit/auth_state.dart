import 'package:equatable/equatable.dart';
import 'package:mobile/product/report/model/report_models.dart';

class AuthState extends Equatable {
  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  final bool isLoading;
  final String? error;
  final UserDto? user;

  AuthState copyWith({
    bool? isLoading,
    String? error,
    UserDto? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, user];
}