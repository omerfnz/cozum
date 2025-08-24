import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'auth.g.dart';

/// Login request model
@JsonSerializable()
final class LoginRequest extends Equatable {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);

  final String email;
  final String password;

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  List<Object?> get props => [email, password];
}

/// Register request model
@JsonSerializable()
final class RegisterRequest extends Equatable {
  const RegisterRequest({
    required this.email,
    required this.username,
    required this.password,
    required this.passwordConfirm,
    this.role = UserRole.vatandas,
    this.firstName,
    this.lastName,
    this.phone,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);

  final String email;
  final String username;
  final String password;
  
  @JsonKey(name: 'password_confirm')
  final String passwordConfirm;
  
  final UserRole role;
  
  @JsonKey(name: 'first_name')
  final String? firstName;
  
  @JsonKey(name: 'last_name')
  final String? lastName;
  
  final String? phone;

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);

  @override
  List<Object?> get props => [
        email,
        username,
        password,
        passwordConfirm,
        role,
        firstName,
        lastName,
        phone,
      ];
}

/// Authentication response model
@JsonSerializable()
final class AuthResponse extends Equatable {
  const AuthResponse({
    required this.access,
    required this.refresh,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);

  final String access;
  final String refresh;
  final User? user;

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  @override
  List<Object?> get props => [access, refresh, user];
}

/// Token refresh request model
@JsonSerializable()
final class TokenRefreshRequest extends Equatable {
  const TokenRefreshRequest({
    required this.refresh,
  });

  factory TokenRefreshRequest.fromJson(Map<String, dynamic> json) => _$TokenRefreshRequestFromJson(json);

  final String refresh;

  Map<String, dynamic> toJson() => _$TokenRefreshRequestToJson(this);

  @override
  List<Object?> get props => [refresh];
}

/// Token refresh response model
@JsonSerializable()
final class TokenRefreshResponse extends Equatable {
  const TokenRefreshResponse({
    required this.access,
    this.refresh,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) => _$TokenRefreshResponseFromJson(json);

  final String access;
  final String? refresh;

  Map<String, dynamic> toJson() => _$TokenRefreshResponseToJson(this);

  @override
  List<Object?> get props => [access, refresh];
}

/// Change password request model
@JsonSerializable()
final class ChangePasswordRequest extends Equatable {
  const ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.newPasswordConfirm,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) => _$ChangePasswordRequestFromJson(json);

  @JsonKey(name: 'old_password')
  final String oldPassword;
  
  @JsonKey(name: 'new_password')
  final String newPassword;
  
  @JsonKey(name: 'new_password_confirm')
  final String newPasswordConfirm;

  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);

  @override
  List<Object?> get props => [oldPassword, newPassword, newPasswordConfirm];
}

/// Update profile request model
@JsonSerializable()
final class UpdateProfileRequest extends Equatable {
  const UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateProfileRequestFromJson(json);

  @JsonKey(name: 'first_name')
  final String? firstName;
  
  @JsonKey(name: 'last_name')
  final String? lastName;
  
  final String? phone;
  final String? address;

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);

  @override
  List<Object?> get props => [firstName, lastName, phone, address];
}