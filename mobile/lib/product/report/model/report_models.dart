import 'package:equatable/equatable.dart';

class UserDto extends Equatable {
  const UserDto({
    required this.id,
    required this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.role,
    this.roleDisplay,
    this.team,
    this.teamName,
    this.phone,
    this.address,
    this.dateJoined,
    this.lastLogin,
  });

  final int id;
  final String email;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? role;
  final String? roleDisplay;
  final int? team;
  final String? teamName;
  final String? phone;
  final String? address;
  final DateTime? dateJoined;
  final DateTime? lastLogin;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v as String);
      } catch (_) {
        return null;
      }
    }

    return UserDto(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String? ?? '',
      username: json['username'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      role: json['role'] as String?,
      roleDisplay: json['role_display'] as String?,
      team: (json['team'] as num?)?.toInt(),
      teamName: json['team_name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      dateJoined: parseDate(json['date_joined']),
      lastLogin: parseDate(json['last_login']),
    );
  }

  @override
  List<Object?> get props => [id, email];
}

class CategoryDto extends Equatable {
  const CategoryDto({
    required this.id,
    required this.name,
    this.description,
    this.isActive,
  });

  final int id;
  final String name;
  final String? description;
  final bool? isActive;

  factory CategoryDto.fromJson(Map<String, dynamic> json) => CategoryDto(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        isActive: json['is_active'] as bool?,
      );

  @override
  List<Object?> get props => [id, name];
}

class TeamDto extends Equatable {
  const TeamDto({
    required this.id,
    required this.name,
    this.description,
    this.teamType,
    this.createdBy,
    this.createdByName,
    this.membersCount,
    this.createdAt,
    this.isActive,
  });

  final int id;
  final String name;
  final String? description;
  final String? teamType;
  final int? createdBy;
  final String? createdByName;
  final int? membersCount;
  final DateTime? createdAt;
  final bool? isActive;

  factory TeamDto.fromJson(Map<String, dynamic> json) {
    DateTime? createdAt;
    final raw = json['created_at'];
    if (raw is String) {
      try {
        createdAt = DateTime.parse(raw);
      } catch (_) {}
    }

    return TeamDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      teamType: json['team_type'] as String?,
      createdBy: (json['created_by'] as num?)?.toInt(),
      createdByName: json['created_by_name'] as String?,
      membersCount: (json['members_count'] as num?)?.toInt(),
      createdAt: createdAt,
      isActive: json['is_active'] as bool?,
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class ReportListItem extends Equatable {
  const ReportListItem({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.reporter,
    required this.category,
    this.assignedTeam,
    this.location,
    required this.createdAt,
    required this.updatedAt,
    required this.mediaCount,
    required this.commentCount,
    this.firstMediaUrl,
  });

  final int id;
  final String title;
  final String status;
  final String priority;
  final UserDto reporter;
  final CategoryDto category;
  final TeamDto? assignedTeam;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int mediaCount;
  final int commentCount;
  final String? firstMediaUrl;

  factory ReportListItem.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(String key) {
      final v = json[key];
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {}
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return ReportListItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      reporter: UserDto.fromJson((json['reporter'] as Map).cast<String, dynamic>()),
      category: CategoryDto.fromJson((json['category'] as Map).cast<String, dynamic>()),
      assignedTeam: json['assigned_team'] == null
          ? null
          : TeamDto.fromJson((json['assigned_team'] as Map).cast<String, dynamic>()),
      location: json['location'] as String?,
      createdAt: parseDate('created_at'),
      updatedAt: parseDate('updated_at'),
      mediaCount: (json['media_count'] as num? ?? 0).toInt(),
      commentCount: (json['comment_count'] as num? ?? 0).toInt(),
      firstMediaUrl: json['first_media_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, title, status, priority, createdAt, updatedAt];
}

class ReportPage {
  ReportPage({required this.items, this.nextUrl});

  final List<ReportListItem> items;
  final String? nextUrl;
}

class MediaDto extends Equatable {
  const MediaDto({
    required this.id,
    this.fileUrl,
    this.filePath,
    this.fileSize,
    this.mediaType,
    this.uploadedAt,
  });

  final int id;
  final String? fileUrl; // serializer'da "file" alanı
  final String? filePath;
  final int? fileSize;
  final String? mediaType;
  final DateTime? uploadedAt;

  factory MediaDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v as String);
      } catch (_) {
        return null;
      }
    }

    return MediaDto(
      id: (json['id'] as num).toInt(),
      fileUrl: json['file'] as String?,
      filePath: json['file_path'] as String?,
      fileSize: (json['file_size'] as num?)?.toInt(),
      mediaType: json['media_type'] as String?,
      uploadedAt: parseDate(json['uploaded_at']),
    );
  }

  @override
  List<Object?> get props => [id, fileUrl, filePath];
}

class CommentDto extends Equatable {
  const CommentDto({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
  });

  final int id;
  final UserDto user;
  final String content;
  final DateTime createdAt;

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      try {
        return DateTime.parse(v as String);
      } catch (_) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
    }

    return CommentDto(
      id: (json['id'] as num).toInt(),
      user: UserDto.fromJson((json['user'] as Map).cast<String, dynamic>()),
      content: json['content'] as String? ?? '',
      createdAt: parseDate(json['created_at']),
    );
  }

  @override
  List<Object?> get props => [id, content, createdAt];
}

class ReportDetail extends Equatable {
  const ReportDetail({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.reporter,
    required this.category,
    this.assignedTeam,
    this.location,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
    required this.mediaFiles,
    required this.comments,
  });

  final int id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final UserDto reporter;
  final CategoryDto category;
  final TeamDto? assignedTeam;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MediaDto> mediaFiles;
  final List<CommentDto> comments;

  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {}
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return ReportDetail(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      reporter: UserDto.fromJson((json['reporter'] as Map).cast<String, dynamic>()),
      category: CategoryDto.fromJson((json['category'] as Map).cast<String, dynamic>()),
      assignedTeam: json['assigned_team'] == null
          ? null
          : TeamDto.fromJson((json['assigned_team'] as Map).cast<String, dynamic>()),
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      mediaFiles: (json['media_files'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => MediaDto.fromJson(e))
          .toList(growable: false),
      comments: (json['comments'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((e) => CommentDto.fromJson(e))
          .toList(growable: false),
    );
  }

  @override
  List<Object?> get props => [id, title, status, priority, createdAt, updatedAt];
}