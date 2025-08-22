import 'package:flutter/material.dart';
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/navigation/app_router.dart';

final _appRouter = AppRouter();

/// Uygulama giriş noktası
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/',
  );
  await setupLocator(apiBaseUrl: baseUrl);
  runApp(const MyApp());
}

/// Uygulamanın kök widget'ı
final class MyApp extends StatelessWidget {
  /// Varsayılan kurucu
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cozum Var',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
      ),
      routerConfig: _appRouter.config(),
    );
  }
}
