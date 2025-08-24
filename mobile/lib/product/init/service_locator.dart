import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../service/network/network_service.dart';
import '../service/network/dio_interceptor.dart';
import '../service/storage/storage_service.dart';
import '../service/auth/auth_service.dart';
import '../navigation/app_router.dart';
import '../theme/theme_cubit.dart';

/// Service locator instance
final GetIt serviceLocator = GetIt.instance;

/// Initialize all dependencies
Future<void> setupServiceLocator() async {
  // Core services
  serviceLocator.registerLazySingleton<Logger>(() => Logger());
  
  // Storage
  serviceLocator.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  
  serviceLocator.registerLazySingleton<IStorageService>(
    () => StorageService(serviceLocator<FlutterSecureStorage>()),
  );
  
  // Network
  serviceLocator.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8000/api/',
    );
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
    dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    
    // Add logging interceptor in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) => serviceLocator<Logger>().d(obj),
        ),
      );
    }
    
    return dio;
  });
  
  serviceLocator.registerLazySingleton<INetworkService>(
    () {
      final dio = serviceLocator<Dio>();
      final storageService = serviceLocator<IStorageService>();
      final logger = serviceLocator<Logger>();
      
      // Add authentication interceptor
      dio.interceptors.add(
        AuthInterceptor(
          storageService: storageService,
          logger: logger,
        ),
      );
      
      // Add error handling interceptor
      dio.interceptors.add(
        ErrorInterceptor(logger: logger),
      );
      
      return NetworkService(dio);
    },
  );
  
  // Auth Service
  serviceLocator.registerLazySingleton<IAuthService>(
    () => AuthService(
      serviceLocator<INetworkService>(),
      serviceLocator<IStorageService>(),
    ),
  );
  
  // Navigation
  serviceLocator.registerLazySingleton<AppRouter>(() => AppRouter());
  
  // Theme
  serviceLocator.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
}

/// Clean up all dependencies
Future<void> cleanupServiceLocator() async {
  await serviceLocator.reset();
}