import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/product/auth/auth_repository.dart';
import 'package:mobile/product/auth/token_storage.dart';
import 'package:mobile/product/config/app_config.dart';
import 'package:mobile/product/report/report_repository.dart';

/// Uygulama genel bağımlılık konteyneri
final GetIt di = GetIt.instance;

/// Servis sağlayıcılarını ve istemcileri hazırlar
Future<void> setupLocator({required String apiBaseUrl}) async {
  // App config ve HTTP istemcisi
  di
    ..registerSingleton<AppConfig>(AppConfig(apiBaseUrl: apiBaseUrl))
    ..registerLazySingleton<TokenStorage>(() => TokenStorage(
          storage: const FlutterSecureStorage(),
        ))
    ..registerLazySingleton<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: const {
            'Content-Type': 'application/json',
          },
        ),
      );

      final storage = di<TokenStorage>();

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final access = await storage.readAccessToken();
          if (access != null && access.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $access';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final response = error.response;
          final req = error.requestOptions;
          final isAuthEndpoint = req.path.contains('auth/login') ||
              req.path.contains('auth/register') ||
              req.path.contains('auth/refresh');

          if (response?.statusCode == 401 && !isAuthEndpoint && req.extra['retried'] != true) {
            final refresh = await storage.readRefreshToken();
            if (refresh != null && refresh.isNotEmpty) {
              try {
                final refreshDio = Dio(BaseOptions(baseUrl: req.baseUrl));
                final refreshRes = await refreshDio.post<Map<String, dynamic>>(
                  'auth/refresh/',
                  data: {'refresh': refresh},
                );
                final newAccess = refreshRes.data?['access'] as String?;
                if (newAccess != null && newAccess.isNotEmpty) {
                  await storage.writeAccessToken(newAccess);
                  req.headers['Authorization'] = 'Bearer $newAccess';
                  req.extra['retried'] = true;
                  final clone = await dio.fetch<dynamic>(req);
                  return handler.resolve(clone);
                }
              } on Object catch (_) {
                await storage.clear();
              }
            }
          }
          handler.next(error);
        },
      ));

      return dio;
    })
    ..registerLazySingleton<AuthRepository>(() => AuthRepository(
          di<Dio>(),
          di<TokenStorage>(),
        ))
    ..registerLazySingleton<ReportRepository>(() => ReportRepository(di<Dio>()));
}
