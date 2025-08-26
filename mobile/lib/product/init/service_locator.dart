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
    // Prefer dart-define provided value; otherwise compute from defaults
    final envBase = const String.fromEnvironment('API_BASE_URL', defaultValue: '');
    final computedBase = envBase.isNotEmpty ? envBase : _computeDefaultBaseUrl();
    dio.options.baseUrl = _normalizeBaseUrl(computedBase);
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
          requestHeader: false, // Disable to avoid logging sensitive headers
          responseHeader: false,
          error: true,
          logPrint: (obj) {
            try {
              final msg = obj.toString();
              if (msg.isEmpty) return;
              // Basit ve güvenli log: uzun mesajları kısalt, ek işlem yapma
              final out = msg.length > 4000
                  ? '${msg.substring(0, 4000)}... (truncated, total=${msg.length})'
                  : msg;
              serviceLocator<Logger>().d(out);
            } catch (e) {
              // Eğer log yazımında hata olursa sessizce yut, uygulama akışını etkileme
            }
          },
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

// --- Base URL helpers ---
String _computeDefaultBaseUrl() {
  // Varsayılan olarak prod domaini kullan (HTTPS tercih edilir)
  const host = 'api.ntek.com.tr';
  // İleriye dönük: platforma göre farklılaştırmak gerekirse kIsWeb / defaultTargetPlatform kullanılabilir
  return 'https://$host';
}

String _normalizeBaseUrl(String raw) {
  var url = raw.trim();
  // FQDN’de sonda nokta varsa temizle ("api.ntek.com.tr.")
  if (url.endsWith('.')) {
    url = url.substring(0, url.length - 1);
  }
  // Şema yoksa HTTPS varsay
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://$url';
  }
  // Uri parse ederek pathSegments üzerinden /api/ segmentini garanti et
  Uri? parsed;
  try {
    parsed = Uri.parse(url);
  } catch (_) {
    parsed = null;
  }
  if (parsed != null) {
    final segments = List<String>.from(parsed.pathSegments);
    if (segments.isEmpty || segments.first != 'api') {
      segments.insert(0, 'api');
    }
    // Sonda slash olsun diye boş segment ekle
    if (segments.isEmpty || segments.last.isNotEmpty) {
      segments.add('');
    }
    final normalized = parsed.replace(pathSegments: segments);
    return normalized.toString();
  }
  // Parse başarısızsa güvenli fallback
  if (!url.endsWith('/')) url = '$url/';
  if (!url.contains('/api/')) url = '${url}api/';
  return url;
}