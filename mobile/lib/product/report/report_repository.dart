import 'package:dio/dio.dart';
import 'package:mobile/product/report/model/report_models.dart';

/// Bildirim (Report) işlemleri için repository
final class ReportRepository {
  ReportRepository(this._dio);

  final Dio _dio;

  /// Sayfalama bilgisi ile birlikte bildirim listesini getirir.
  /// DRF pagination varsa `results` ve `next` alanlarını kullanır;
  /// yoksa tüm listeyi döndürür ve `nextUrl` null olur.
  Future<ReportPage> fetchPage({String? scope, String? pageUrl}) async {
    Response<dynamic> res;
    if (pageUrl != null && pageUrl.isNotEmpty) {
      res = await _dio.get<dynamic>(pageUrl);
    } else {
      res = await _dio.get<dynamic>(
        'reports/',
        queryParameters: {
          if (scope != null && scope.isNotEmpty) 'scope': scope,
        },
      );
    }

    final data = res.data;
    List<dynamic> rawItems;
    String? nextUrl;

    if (data is Map<String, dynamic>) {
      if (data['results'] is List) {
        rawItems = (data['results'] as List).cast<dynamic>();
      } else {
        rawItems = const [];
      }
      nextUrl = data['next'] as String?;
    } else if (data is List) {
      rawItems = data;
      nextUrl = null;
    } else {
      rawItems = const [];
      nextUrl = null;
    }

    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map((e) => ReportListItem.fromJson(e))
        .toList(growable: false);

    return ReportPage(items: items, nextUrl: nextUrl);
  }

  /// Geriye dönük uyumluluk için basit liste dönüşü
  Future<List<ReportListItem>> listReports({String? scope}) async {
    final page = await fetchPage(scope: scope);
    return page.items;
  }

  /// Tekil rapor detayını getirir
  Future<ReportDetail> fetchDetail(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('reports/$id/');
    final data = res.data ?? const <String, dynamic>{};
    return ReportDetail.fromJson(data);
  }

  /// Kategori listesini getirir
  Future<List<CategoryDto>> fetchCategories() async {
    final res = await _dio.get<dynamic>('categories/');
    final data = res.data;
    List<dynamic> raw = const [];
    if (data is List) {
      raw = data;
    } else if (data is Map<String, dynamic>) {
      if (data['results'] is List) raw = data['results'] as List;
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map((e) => CategoryDto.fromJson(e))
        .toList(growable: false);
  }

  /// Yeni rapor oluşturur. Görselleri `media_files` alanıyla yükler.
  Future<int> createReport({
    required String title,
    String? description,
    required int categoryId,
    String? location,
    double? latitude,
    double? longitude,
    List<String> imagePaths = const [],
  }) async {
    final files = await Future.wait(imagePaths.map((p) async => await MultipartFile.fromFile(p)));
    final form = FormData.fromMap({
      'title': title,
      if (description != null) 'description': description,
      'category': categoryId,
      if (location != null) 'location': location,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (files.isNotEmpty) 'media_files': files,
    });
    final res = await _dio.post<Map<String, dynamic>>(
      'reports/',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    final id = res.data?['id'];
    if (id is num) return id.toInt();
    throw DioException(requestOptions: res.requestOptions, message: 'Oluşturma başarısız');
  }

  /// Rapor yorumlarına yeni yorum ekler
  Future<CommentDto> addComment({required int reportId, required String content}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'reports/$reportId/comments/',
      data: {'content': content},
    );
    final data = res.data ?? const <String, dynamic>{};
    return CommentDto.fromJson(data);
  }
}