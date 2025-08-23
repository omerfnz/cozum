import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mobile/product/auth/auth_repository.dart';
import 'package:mobile/product/auth/token_storage.dart';
import 'package:mobile/product/config/app_config.dart';
import 'package:mobile/product/navigation/app_router.dart';
import 'package:mobile/product/report/report_repository.dart';
import 'package:oktoast/oktoast.dart';

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
    ..registerLazySingleton<Logger>(() => Logger(
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 5,
            lineLength: 100,
            colors: false,
            printEmojis: false,
            dateTimeFormat: DateTimeFormat.onlyTime,
          ),
          level: Level.debug,
        ))
    ..registerLazySingleton<AppRouter>(() => AppRouter())
    ..registerLazySingleton<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
          headers: const {
            'Content-Type': 'application/json',
          },
        ),
      );

      final storage = di<TokenStorage>();
      final logger = di<Logger>();
      // Başlangıçta seçilen API baseUrl bilgisini logla
      logger.i('[Init] API baseUrl: $apiBaseUrl');

      // Basit HTTP loglayıcı (Authorization maskeli)
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.extra['__startTime'] = DateTime.now();
          final hasAuth = (options.headers['Authorization'] ?? '').toString().isNotEmpty;
          logger.i('[HTTP] -> ${options.method} ${options.baseUrl}${options.path} ${options.queryParameters.isNotEmpty ? options.queryParameters : ''} ${hasAuth ? '(auth: ****)' : ''}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          final start = response.requestOptions.extra['__startTime'] as DateTime?;
          final took = start != null ? DateTime.now().difference(start).inMilliseconds : null;
          logger.i('[HTTP] <- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path} ${took != null ? '(${took}ms)' : ''}');
          handler.next(response);
        },
        onError: (error, handler) {
          final req = error.requestOptions;
          logger.e('[HTTP] !! ${req.method} ${req.path} -> ${error.message} ${error.response?.statusCode != null ? '(code ${error.response?.statusCode})' : ''}');
          handler.next(error);
        },
      ));

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
                } else {
                  // access gelmediyse oturumu kapat
                  await storage.clear();
                  showToast('Oturum süreniz doldu. Lütfen tekrar giriş yapın.');
                  try {
                    final router = di<AppRouter>();
                    router.replaceAll([const LoginRoute()]);
                  } catch (_) {}
                }
              } on Object catch (_) {
                await storage.clear();
                showToast('Oturum süreniz doldu. Lütfen tekrar giriş yapın.');
                try {
                  final router = di<AppRouter>();
                  router.replaceAll([const LoginRoute()]);
                } catch (_) {}
              }
            } else {
              // refresh yoksa doğrudan oturumu kapat
              await storage.clear();
              showToast('Oturum süreniz doldu. Lütfen tekrar giriş yapın.');
              try {
                final router = di<AppRouter>();
                router.replaceAll([const LoginRoute()]);
              } catch (_) {}
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
