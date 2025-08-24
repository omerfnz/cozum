// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    ApiResponse<T>(
      count: (json['count'] as num?)?.toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>?)?.map(fromJsonT).toList(),
    );

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results?.map(toJsonT).toList(),
    };

CreateReportRequest _$CreateReportRequestFromJson(Map<String, dynamic> json) =>
    CreateReportRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      categoryId: (json['category'] as num).toInt(),
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      priority:
          $enumDecodeNullable(_$ReportPriorityEnumMap, json['priority']) ??
              ReportPriority.orta,
    );

Map<String, dynamic> _$CreateReportRequestToJson(
        CreateReportRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'category': instance.categoryId,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'priority': _$ReportPriorityEnumMap[instance.priority]!,
    };

const _$ReportPriorityEnumMap = {
  ReportPriority.dusuk: 'DUSUK',
  ReportPriority.orta: 'ORTA',
  ReportPriority.yuksek: 'YUKSEK',
  ReportPriority.acil: 'ACIL',
};

UpdateReportRequest _$UpdateReportRequestFromJson(Map<String, dynamic> json) =>
    UpdateReportRequest(
      status: $enumDecodeNullable(_$ReportStatusEnumMap, json['status']),
      priority: $enumDecodeNullable(_$ReportPriorityEnumMap, json['priority']),
      assignedTeamId: (json['assigned_team'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UpdateReportRequestToJson(
        UpdateReportRequest instance) =>
    <String, dynamic>{
      'status': _$ReportStatusEnumMap[instance.status],
      'priority': _$ReportPriorityEnumMap[instance.priority],
      'assigned_team': instance.assignedTeamId,
    };

const _$ReportStatusEnumMap = {
  ReportStatus.beklemede: 'BEKLEMEDE',
  ReportStatus.inceleniyor: 'INCELENIYOR',
  ReportStatus.cozuldu: 'COZULDU',
  ReportStatus.reddedildi: 'REDDEDILDI',
};

AddCommentRequest _$AddCommentRequestFromJson(Map<String, dynamic> json) =>
    AddCommentRequest(
      content: json['content'] as String,
    );

Map<String, dynamic> _$AddCommentRequestToJson(AddCommentRequest instance) =>
    <String, dynamic>{
      'content': instance.content,
    };

HealthResponse _$HealthResponseFromJson(Map<String, dynamic> json) =>
    HealthResponse(
      status: json['status'] as String,
      storage: json['storage'] == null
          ? null
          : StorageInfo.fromJson(json['storage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HealthResponseToJson(HealthResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'storage': instance.storage,
    };

StorageInfo _$StorageInfoFromJson(Map<String, dynamic> json) => StorageInfo(
      type: json['type'] as String,
      writeTest: json['write_test'] as String,
      cleanup: json['cleanup'] as String,
    );

Map<String, dynamic> _$StorageInfoToJson(StorageInfo instance) =>
    <String, dynamic>{
      'type': instance.type,
      'write_test': instance.writeTest,
      'cleanup': instance.cleanup,
    };
