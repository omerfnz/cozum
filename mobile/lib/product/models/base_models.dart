import 'package:equatable/equatable.dart';

/// Base model class that all models should extend
abstract class BaseModel extends Equatable {
  const BaseModel();
  
  /// Convert model to JSON
  Map<String, dynamic> toJson();
  
  /// Create model from JSON
  static BaseModel fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented in child classes');
  }
}

/// User roles enum
enum UserRole {
  vatandas('VATANDAS'),
  ekip('EKIP'), 
  operator('OPERATOR'),
  admin('ADMIN');
  
  const UserRole(this.value);
  final String value;
  
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.vatandas,
    );
  }
}

/// Report status enum
enum ReportStatus {
  beklemede('BEKLEMEDE'),
  inceleniyor('INCELENIYOR'),
  cozuldu('COZULDU'),
  reddedildi('REDDEDILDI');
  
  const ReportStatus(this.value);
  final String value;
  
  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReportStatus.beklemede,
    );
  }
}

/// Report priority enum
enum ReportPriority {
  dusuk('DUSUK'),
  orta('ORTA'),
  yuksek('YUKSEK'),
  acil('ACIL');
  
  const ReportPriority(this.value);
  final String value;
  
  static ReportPriority fromString(String value) {
    return ReportPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => ReportPriority.dusuk,
    );
  }
}

/// Team type enum
enum TeamType {
  teknik('TEKNIK'),
  operasyon('OPERASYON'),
  destek('DESTEK'),
  yonetim('YONETIM');
  
  const TeamType(this.value);
  final String value;
  
  static TeamType fromString(String value) {
    return TeamType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TeamType.teknik,
    );
  }
}

/// Media type enum
enum MediaType {
  image('IMAGE'),
  video('VIDEO'),
  document('DOCUMENT'),
  audio('AUDIO');
  
  const MediaType(this.value);
  final String value;
  
  static MediaType fromString(String value) {
    return MediaType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MediaType.image,
    );
  }
}

/// API error model
final class ApiError extends BaseModel {
  const ApiError({
    required this.message,
    this.code,
    this.details,
    this.field,
  });
  
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] as String? ?? 'Unknown error',
      code: json['code'] as String?,
      details: json['details'] as String?,
      field: json['field'] as String?,
    );
  }
  
  final String message;
  final String? code;
  final String? details;
  final String? field;
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'code': code,
      'details': details,
      'field': field,
    };
  }
  
  @override
  List<Object?> get props => [message, code, details, field];
}

/// Generic paginated response model
final class PaginatedResponse<T> extends BaseModel {
  const PaginatedResponse({
    required this.results,
    required this.count,
    required this.totalPages,
    required this.currentPage,
    this.next,
    this.previous,
  });
  
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final results = (json['results'] as List<dynamic>? ?? [])
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();
    
    return PaginatedResponse<T>(
      results: results,
      count: json['count'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );
  }
  
  final List<T> results;
  final int count;
  final int totalPages;
  final int currentPage;
  final String? next;
  final String? previous;
  
  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;
  bool get isEmpty => results.isEmpty;
  bool get isNotEmpty => results.isNotEmpty;
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'results': results,
      'count': count,
      'total_pages': totalPages,
      'current_page': currentPage,
      'next': next,
      'previous': previous,
    };
  }
  
  @override
  List<Object?> get props => [
        results,
        count,
        totalPages,
        currentPage,
        next,
        previous,
      ];
}

/// Location model for geographic coordinates
final class Location extends BaseModel {
  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.district,
    this.neighborhood,
  });
  
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      neighborhood: json['neighborhood'] as String?,
    );
  }
  
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? district;
  final String? neighborhood;
  
  bool get isValid => latitude != 0.0 && longitude != 0.0;
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'district': district,
      'neighborhood': neighborhood,
    };
  }
  
  @override
  List<Object?> get props => [
        latitude,
        longitude,
        address,
        city,
        district,
        neighborhood,
      ];
}