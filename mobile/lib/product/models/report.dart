import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'report.g.dart';

/// Report status enum matching backend choices
enum ReportStatus {
  @JsonValue('BEKLEMEDE')
  beklemede('BEKLEMEDE', 'Beklemede'),
  @JsonValue('INCELENIYOR')
  inceleniyor('INCELENIYOR', 'İnceleniyor'),
  @JsonValue('COZULDU')
  cozuldu('COZULDU', 'Çözüldü'),
  @JsonValue('REDDEDILDI')
  reddedildi('REDDEDILDI', 'Reddedildi');

  const ReportStatus(this.value, this.displayName);
  
  final String value;
  final String displayName;
}

/// Report priority enum matching backend choices
enum ReportPriority {
  @JsonValue('DUSUK')
  dusuk('DUSUK', 'Düşük'),
  @JsonValue('ORTA')
  orta('ORTA', 'Orta'),
  @JsonValue('YUKSEK')
  yuksek('YUKSEK', 'Yüksek'),
  @JsonValue('ACIL')
  acil('ACIL', 'Acil');

  const ReportPriority(this.value, this.displayName);
  
  final String value;
  final String displayName;
}

/// Media type enum matching backend choices
enum MediaType {
  @JsonValue('IMAGE')
  image('IMAGE', 'Resim'),
  @JsonValue('VIDEO')
  video('VIDEO', 'Video');

  const MediaType(this.value, this.displayName);
  
  final String value;
  final String displayName;
}

/// Category model matching Django backend Category model
@JsonSerializable()
final class Category extends Equatable {
  const Category({
    this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  final int? id;
  final String name;
  final String? description;
  
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  List<Object?> get props => [id, name, description, isActive, createdAt];

  Category copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Media model matching Django backend Media model
@JsonSerializable()
final class Media extends Equatable {
  const Media({
    this.id,
    required this.reportId,
    required this.file,
    this.filePath,
    this.fileSize,
    this.mediaType = MediaType.image,
    this.uploadedAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);

  final int? id;
  
  @JsonKey(name: 'report')
  final int reportId;
  
  final String file;
  
  @JsonKey(name: 'file_path')
  final String? filePath;
  
  @JsonKey(name: 'file_size')
  final int? fileSize;
  
  @JsonKey(name: 'media_type')
  final MediaType mediaType;
  
  @JsonKey(name: 'uploaded_at')
  final DateTime? uploadedAt;

  Map<String, dynamic> toJson() => _$MediaToJson(this);

  @override
  List<Object?> get props => [
        id,
        reportId,
        file,
        filePath,
        fileSize,
        mediaType,
        uploadedAt,
      ];

  Media copyWith({
    int? id,
    int? reportId,
    String? file,
    String? filePath,
    int? fileSize,
    MediaType? mediaType,
    DateTime? uploadedAt,
  }) {
    return Media(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      file: file ?? this.file,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      mediaType: mediaType ?? this.mediaType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}

/// Comment model matching Django backend Comment model
@JsonSerializable()
final class Comment extends Equatable {
  const Comment({
    this.id,
    required this.reportId,
    required this.user,
    required this.content,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  final int? id;
  
  @JsonKey(name: 'report')
  final int reportId;
  
  final User user;
  final String content;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => _$CommentToJson(this);

  @override
  List<Object?> get props => [id, reportId, user, content, createdAt];

  Comment copyWith({
    int? id,
    int? reportId,
    User? user,
    String? content,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      user: user ?? this.user,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Report model matching Django backend Report model
@JsonSerializable()
final class Report extends Equatable {
  const Report({
    this.id,
    required this.title,
    required this.description,
    this.status = ReportStatus.beklemede,
    this.priority = ReportPriority.orta,
    required this.reporter,
    required this.category,
    this.assignedTeam,
    this.location,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.mediaFiles,
    this.comments,
    this.firstMediaUrlApi,
  });

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

  final int? id;
  final String title;
  final String description;
  final ReportStatus status;
  final ReportPriority priority;
  final User reporter;
  final Category category;
  
  @JsonKey(name: 'assigned_team')
  final Team? assignedTeam;
  
  final String? location;
  final double? latitude;
  final double? longitude;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  
  @JsonKey(name: 'media_files')
  final List<Media>? mediaFiles;
  
  final List<Comment>? comments;

  /// Backend ReportListSerializer’dan gelen ilk görsel URL’si
  @JsonKey(name: 'first_media_url')
  final String? firstMediaUrlApi;

  Map<String, dynamic> toJson() => _$ReportToJson(this);

  /// Get formatted date string
  String get formattedDate {
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  /// Get first media file URL
  String? get firstMediaUrl {
    String? url;
    if (mediaFiles?.isNotEmpty ?? false) {
      url = mediaFiles!.first.file;
    } else {
      url = firstMediaUrlApi;
    }
    if (url == null) return null;
    // Trim ve etrafına gelmiş olası tırnak/backtick/boşluk karakterlerini temizle
    // Trim ve etrafına gelmiş olası tırnak/backtick/boşluk karakterlerini temizle
    final cleaned = url.trim().replaceAll(RegExp(r'''^[`'"\s]+|[`'"\s]+$'''), '');
    return cleaned;
  }

  /// Check if report has media
  bool get hasMedia => (mediaFiles?.isNotEmpty ?? false) || (firstMediaUrlApi != null && firstMediaUrlApi!.isNotEmpty);

  /// Check if report has comments
  bool get hasComments => comments?.isNotEmpty ?? false;

  /// Get comment count
  int get commentCount => comments?.length ?? 0;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        priority,
        reporter,
        category,
        assignedTeam,
        location,
        latitude,
        longitude,
        createdAt,
        updatedAt,
        mediaFiles,
        comments,
        firstMediaUrlApi,
      ];

  Report copyWith({
    int? id,
    String? title,
    String? description,
    ReportStatus? status,
    ReportPriority? priority,
    User? reporter,
    Category? category,
    Team? assignedTeam,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Media>? mediaFiles,
    List<Comment>? comments,
    String? firstMediaUrlApi,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      reporter: reporter ?? this.reporter,
      category: category ?? this.category,
      assignedTeam: assignedTeam ?? this.assignedTeam,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      comments: comments ?? this.comments,
      firstMediaUrlApi: firstMediaUrlApi ?? this.firstMediaUrlApi,
    );
  }
}