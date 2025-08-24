import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'report.dart';

part 'api_response.g.dart';

/// Generic API response wrapper
@JsonSerializable(genericArgumentFactories: true)
final class ApiResponse<T> extends Equatable {
  const ApiResponse({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);

  final int? count;
  final String? next;
  final String? previous;
  final List<T>? results;

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) => _$ApiResponseToJson(this, toJsonT);

  @override
  List<Object?> get props => [count, next, previous, results];
}

/// Create report request model
@JsonSerializable()
final class CreateReportRequest extends Equatable {
  const CreateReportRequest({
    required this.title,
    required this.description,
    required this.categoryId,
    this.location,
    this.latitude,
    this.longitude,
    this.priority = ReportPriority.orta,
  });

  factory CreateReportRequest.fromJson(Map<String, dynamic> json) => _$CreateReportRequestFromJson(json);

  final String title;
  final String description;
  
  @JsonKey(name: 'category')
  final int categoryId;
  
  @JsonKey(name: 'location')
  final String? location;
  
  final double? latitude;
  final double? longitude;
  final ReportPriority priority;

  Map<String, dynamic> toJson() => _$CreateReportRequestToJson(this);

  @override
  List<Object?> get props => [
        title,
        description,
        categoryId,
        location,
        latitude,
        longitude,
        priority,
      ];
}

/// Update report request model
@JsonSerializable()
final class UpdateReportRequest extends Equatable {
  const UpdateReportRequest({
    this.status,
    this.priority,
    this.assignedTeamId,
  });

  factory UpdateReportRequest.fromJson(Map<String, dynamic> json) => _$UpdateReportRequestFromJson(json);

  final ReportStatus? status;
  final ReportPriority? priority;
  
  @JsonKey(name: 'assigned_team')
  final int? assignedTeamId;

  Map<String, dynamic> toJson() => _$UpdateReportRequestToJson(this);

  @override
  List<Object?> get props => [status, priority, assignedTeamId];
}

/// Add comment request model
@JsonSerializable()
final class AddCommentRequest extends Equatable {
  const AddCommentRequest({
    required this.content,
  });

  factory AddCommentRequest.fromJson(Map<String, dynamic> json) => _$AddCommentRequestFromJson(json);

  @JsonKey(name: 'content')
  final String content;

  Map<String, dynamic> toJson() => _$AddCommentRequestToJson(this);

  @override
  List<Object?> get props => [content];
}

/// Health check response model
@JsonSerializable()
final class HealthResponse extends Equatable {
  const HealthResponse({
    required this.status,
    this.storage,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) => _$HealthResponseFromJson(json);

  final String status;
  final StorageInfo? storage;

  Map<String, dynamic> toJson() => _$HealthResponseToJson(this);

  @override
  List<Object?> get props => [status, storage];
}

/// Storage info model for health check
@JsonSerializable()
final class StorageInfo extends Equatable {
  const StorageInfo({
    required this.type,
    required this.writeTest,
    required this.cleanup,
  });

  factory StorageInfo.fromJson(Map<String, dynamic> json) => _$StorageInfoFromJson(json);

  final String type;
  
  @JsonKey(name: 'write_test')
  final String writeTest;
  
  final String cleanup;

  Map<String, dynamic> toJson() => _$StorageInfoToJson(this);

  @override
  List<Object?> get props => [type, writeTest, cleanup];
}