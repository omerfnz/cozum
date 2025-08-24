// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num?)?.toInt(),
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      team: json['team'] == null
          ? null
          : Team.fromJson(json['team'] as Map<String, dynamic>),
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      dateJoined: json['date_joined'] == null
          ? null
          : DateTime.parse(json['date_joined'] as String),
      lastLogin: json['last_login'] == null
          ? null
          : DateTime.parse(json['last_login'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'role': _$UserRoleEnumMap[instance.role]!,
      'team': instance.team,
      'phone': instance.phone,
      'address': instance.address,
      'is_active': instance.isActive,
      'date_joined': instance.dateJoined?.toIso8601String(),
      'last_login': instance.lastLogin?.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.vatandas: 'VATANDAS',
  UserRole.ekip: 'EKIP',
  UserRole.operator: 'OPERATOR',
  UserRole.admin: 'ADMIN',
};

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      teamType: $enumDecode(_$TeamTypeEnumMap, json['team_type']),
      createdBy: (json['created_by'] as num?)?.toInt(),
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
      createdByName: json['created_by_name'] as String?,
    );

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'team_type': _$TeamTypeEnumMap[instance.teamType]!,
      'created_by': instance.createdBy,
      'members': instance.members,
      'created_at': instance.createdAt?.toIso8601String(),
      'is_active': instance.isActive,
      'member_count': instance.memberCount,
      'created_by_name': instance.createdByName,
    };

const _$TeamTypeEnumMap = {
  TeamType.ekip: 'EKIP',
  TeamType.operator: 'OPERATOR',
  TeamType.admin: 'ADMIN',
};
