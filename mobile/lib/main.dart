import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/navigation/app_router.dart';
import 'package:oktoast/oktoast.dart';

final _appRouter = AppRouter();

/// Uygulama giriş noktası
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // API_BASE_URL build-time ile gelebilir; Android'de localhost/127.0.0.1 kullanımı emulator için 10.0.2.2'ye çevrilir
  const rawBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.101:8000/api/',
  );
  final baseUrl = (Platform.isAndroid && (rawBaseUrl.contains('localhost') || rawBaseUrl.contains('127.0.0.1')))
      ? rawBaseUrl
          .replaceAll('localhost', '10.0.2.2')
          .replaceAll('127.0.0.1', '10.0.2.2')
      : rawBaseUrl;

  await setupLocator(apiBaseUrl: baseUrl);
  runApp(const MyApp());
}

/// Uygulamanın kök widget'ı
final class MyApp extends StatelessWidget {
  /// Varsayılan kurucu
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      position: ToastPosition.bottom,
      dismissOtherOnShow: true,
      backgroundColor: const Color(0xFF000000).withValues(alpha: 0.85),
      radius: 8,
      textStyle: const TextStyle(color: Colors.white),
      child: MaterialApp.router(
        title: 'Cozum Var',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
        ),
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
