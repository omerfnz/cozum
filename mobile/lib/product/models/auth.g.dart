// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      passwordConfirm: json['password_confirm'] as String,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ??
          UserRole.vatandas,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'username': instance.username,
      'password': instance.password,
      'password_confirm': instance.passwordConfirm,
      'role': _$UserRoleEnumMap[instance.role]!,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
    };

const _$UserRoleEnumMap = {
  UserRole.vatandas: 'VATANDAS',
  UserRole.ekip: 'EKIP',
  UserRole.operator: 'OPERATOR',
  UserRole.admin: 'ADMIN',
};

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access': instance.access,
      'refresh': instance.refresh,
      'user': instance.user,
    };

TokenRefreshRequest _$TokenRefreshRequestFromJson(Map<String, dynamic> json) =>
    TokenRefreshRequest(
      refresh: json['refresh'] as String,
    );

Map<String, dynamic> _$TokenRefreshRequestToJson(
        TokenRefreshRequest instance) =>
    <String, dynamic>{
      'refresh': instance.refresh,
    };

TokenRefreshResponse _$TokenRefreshResponseFromJson(
        Map<String, dynamic> json) =>
    TokenRefreshResponse(
      access: json['access'] as String,
      refresh: json['refresh'] as String?,
    );

Map<String, dynamic> _$TokenRefreshResponseToJson(
        TokenRefreshResponse instance) =>
    <String, dynamic>{
      'access': instance.access,
      'refresh': instance.refresh,
    };

ChangePasswordRequest _$ChangePasswordRequestFromJson(
        Map<String, dynamic> json) =>
    ChangePasswordRequest(
      oldPassword: json['old_password'] as String,
      newPassword: json['new_password'] as String,
      newPasswordConfirm: json['new_password_confirm'] as String,
    );

Map<String, dynamic> _$ChangePasswordRequestToJson(
        ChangePasswordRequest instance) =>
    <String, dynamic>{
      'old_password': instance.oldPassword,
      'new_password': instance.newPassword,
      'new_password_confirm': instance.newPasswordConfirm,
    };

UpdateProfileRequest _$UpdateProfileRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateProfileRequest(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$UpdateProfileRequestToJson(
        UpdateProfileRequest instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'address': instance.address,
    };
