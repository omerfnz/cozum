import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'package:mobile/feature/admin/teams/repository/team_repository.dart';
import 'package:mobile/product/auth/auth_repository.dart';
import 'package:mobile/product/auth/token_storage.dart';
import 'package:mobile/product/config/app_config.dart';
import 'package:mobile/product/navigation/app_router.dart';
import 'package:mobile/product/report/report_repository.dart';
import 'package:mobile/product/user/user_repository.dart';

final di = GetIt.I;

Future<void> setupLocator({required String apiBaseUrl}) async {
  // Config
  di.registerSingleton<AppConfig>(AppConfig(apiBaseUrl: apiBaseUrl));
  // Storage
  di.registerLazySingleton<TokenStorage>(() => TokenStorage());
  // Logger
  di.registerLazySingleton<Logger>(() => Logger());
  // Router
  di.registerLazySingleton<AppRouter>(() => AppRouter());

  // Dio
  di.registerLazySingleton<Dio>(() {
    final options = BaseOptions(
      baseUrl: di<AppConfig>().apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    );

    final dio = Dio(options);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await di<TokenStorage>().readAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        di<Logger>().i('[DIO][REQ] ${options.method} ${options.uri}');
        if (options.data != null) di<Logger>().d(options.data);
        handler.next(options);
      },
      onResponse: (response, handler) {
        di<Logger>().i('[DIO][RES] ${response.statusCode} ${response.requestOptions.uri}');
        handler.next(response);
      },
      onError: (error, handler) async {
        di<Logger>().e('[DIO][ERR] ${error.response?.statusCode} ${error.requestOptions.uri}');
        if (error.response?.statusCode == 401) {
          // Try refresh
          final tokenStorage = di<TokenStorage>();
          final refreshToken = await tokenStorage.readRefreshToken();
          if (refreshToken != null) {
            try {
              final ok = await di<AuthRepository>().refresh();
              if (ok) {
                final newAccess = await tokenStorage.readAccessToken();
                final req = error.requestOptions;
                if (newAccess != null) {
                  req.headers['Authorization'] = 'Bearer $newAccess';
                } else {
                  req.headers.remove('Authorization');
                }
                final retry = await dio.fetch(req);
                return handler.resolve(retry);
              } else {
                await tokenStorage.clear();
              }
            } catch (e, st) {
              di<Logger>().e('[AUTH][REFRESH] HATA: $e', stackTrace: st);
              await tokenStorage.clear();
            }
          }
        }
        handler.next(error);
      },
    ));

    return dio;
  });

  // Repositories
  di.registerLazySingleton<AuthRepository>(() => AuthRepository(di<Dio>(), di<TokenStorage>()));
  di.registerLazySingleton<ReportRepository>(() => ReportRepository(di<Dio>()));
  di.registerLazySingleton<UserRepository>(() => UserRepository(di<Dio>()));
  di.registerLazySingleton<TeamRepository>(() => TeamRepository(di<Dio>()));
}
