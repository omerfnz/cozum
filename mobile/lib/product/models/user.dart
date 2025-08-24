import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// User role enum matching backend choices
enum UserRole {
  @JsonValue('VATANDAS')
  vatandas('VATANDAS', 'Vatandaş'),
  @JsonValue('EKIP')
  ekip('EKIP', 'Saha Ekibi'),
  @JsonValue('OPERATOR')
  operator('OPERATOR', 'Operatör'),
  @JsonValue('ADMIN')
  admin('ADMIN', 'Admin');

  const UserRole(this.value, this.displayName);
  
  final String value;
  final String displayName;
}

/// User model matching Django backend User model
@JsonSerializable()
final class User extends Equatable {
  const User({
    this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    required this.role,
    this.team,
    this.phone,
    this.address,
    this.isActive = true,
    this.dateJoined,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  final int? id;
  final String email;
  final String username;
  
  @JsonKey(name: 'first_name')
  final String? firstName;
  
  @JsonKey(name: 'last_name')
  final String? lastName;
  
  final UserRole role;
  final Team? team;
  final String? phone;
  final String? address;
  
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  @JsonKey(name: 'date_joined')
  final DateTime? dateJoined;
  
  @JsonKey(name: 'last_login')
  final DateTime? lastLogin;

  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Full name getter
  String get fullName {
    final parts = [firstName, lastName].where((part) => part?.isNotEmpty ?? false);
    return parts.isEmpty ? username : parts.join(' ');
  }

  /// Display name getter  
  String get displayName => fullName.isNotEmpty ? fullName : email;

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;
  
  /// Check if user is operator
  bool get isOperator => role == UserRole.operator;
  
  /// Check if user is team member
  bool get isTeamMember => role == UserRole.ekip;
  
  /// Check if user is citizen
  bool get isCitizen => role == UserRole.vatandas;

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        firstName,
        lastName,
        role,
        team,
        phone,
        address,
        isActive,
        dateJoined,
        lastLogin,
      ];

  User copyWith({
    int? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    UserRole? role,
    Team? team,
    String? phone,
    String? address,
    bool? isActive,
    DateTime? dateJoined,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      team: team ?? this.team,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

/// Team type enum matching backend choices
enum TeamType {
  @JsonValue('EKIP')
  ekip('EKIP', 'Saha Ekibi'),
  @JsonValue('OPERATOR')
  operator('OPERATOR', 'Operatör Takımı'),
  @JsonValue('ADMIN')
  admin('ADMIN', 'Admin Takımı');

  const TeamType(this.value, this.displayName);
  
  final String value;
  final String displayName;
}

/// Team model matching Django backend Team model
@JsonSerializable()
final class Team extends Equatable {
  const Team({
    this.id,
    required this.name,
    this.description,
    required this.teamType,
    this.createdBy,
    this.members,
    this.createdAt,
    this.isActive = true,
    this.memberCount = 0,
    this.createdByName,
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);

  final int? id;
  final String name;
  final String? description;
  
  @JsonKey(name: 'team_type')
  final TeamType teamType;
  
  @JsonKey(name: 'created_by')
  final int? createdBy;
  
  final List<User>? members;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  @JsonKey(name: 'member_count')
  final int memberCount;
  
  @JsonKey(name: 'created_by_name')
  final String? createdByName;

  Map<String, dynamic> toJson() => _$TeamToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        teamType,
        createdBy,
        members,
        createdAt,
        isActive,
        memberCount,
        createdByName,
      ];

  Team copyWith({
    int? id,
    String? name,
    String? description,
    TeamType? teamType,
    int? createdBy,
    List<User>? members,
    DateTime? createdAt,
    bool? isActive,
    int? memberCount,
    String? createdByName,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teamType: teamType ?? this.teamType,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      memberCount: memberCount ?? this.memberCount,
      createdByName: createdByName ?? this.createdByName,
    );
  }
}