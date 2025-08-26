// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
    };

Media _$MediaFromJson(Map<String, dynamic> json) => Media(
      id: (json['id'] as num?)?.toInt(),
      reportId: (json['report'] as num?)?.toInt(),
      file: json['file'] as String,
      filePath: json['file_path'] as String?,
      fileSize: (json['file_size'] as num?)?.toInt(),
      mediaType: $enumDecodeNullable(_$MediaTypeEnumMap, json['media_type']) ??
          MediaType.image,
      uploadedAt: json['uploaded_at'] == null
          ? null
          : DateTime.parse(json['uploaded_at'] as String),
    );

Map<String, dynamic> _$MediaToJson(Media instance) => <String, dynamic>{
      'id': instance.id,
      'report': instance.reportId,
      'file': instance.file,
      'file_path': instance.filePath,
      'file_size': instance.fileSize,
      'media_type': _$MediaTypeEnumMap[instance.mediaType]!,
      'uploaded_at': instance.uploadedAt?.toIso8601String(),
    };

const _$MediaTypeEnumMap = {
  MediaType.image: 'IMAGE',
  MediaType.video: 'VIDEO',
};

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: (json['id'] as num?)?.toInt(),
      reportId: (json['report'] as num?)?.toInt(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      content: json['content'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'report': instance.reportId,
      'user': instance.user,
      'content': instance.content,
      'created_at': instance.createdAt?.toIso8601String(),
    };

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      status: $enumDecodeNullable(_$ReportStatusEnumMap, json['status']) ??
          ReportStatus.beklemede,
      priority:
          $enumDecodeNullable(_$ReportPriorityEnumMap, json['priority']) ??
              ReportPriority.orta,
      reporter: User.fromJson(json['reporter'] as Map<String, dynamic>),
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      assignedTeam: json['assigned_team'] == null
          ? null
          : Team.fromJson(json['assigned_team'] as Map<String, dynamic>),
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      mediaFiles: (json['media_files'] as List<dynamic>?)
          ?.map((e) => Media.fromJson(e as Map<String, dynamic>))
          .toList(),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstMediaUrlApi: json['first_media_url'] as String?,
      commentCountApi: (json['comment_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': _$ReportStatusEnumMap[instance.status]!,
      'priority': _$ReportPriorityEnumMap[instance.priority]!,
      'reporter': instance.reporter,
      'category': instance.category,
      'assigned_team': instance.assignedTeam,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'media_files': instance.mediaFiles,
      'comments': instance.comments,
      'first_media_url': instance.firstMediaUrlApi,
      'comment_count': instance.commentCountApi,
    };

const _$ReportStatusEnumMap = {
  ReportStatus.beklemede: 'BEKLEMEDE',
  ReportStatus.inceleniyor: 'INCELENIYOR',
  ReportStatus.cozuldu: 'COZULDU',
  ReportStatus.reddedildi: 'REDDEDILDI',
};

const _$ReportPriorityEnumMap = {
  ReportPriority.dusuk: 'DUSUK',
  ReportPriority.orta: 'ORTA',
  ReportPriority.yuksek: 'YUKSEK',
  ReportPriority.acil: 'ACIL',
};
