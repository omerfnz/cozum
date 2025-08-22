import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/product/auth/auth_repository.dart';
import 'package:mobile/product/auth/token_storage.dart';
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/navigation/app_router.dart';

/// Uygulama açılışında kimlik doğrulama durumunu kontrol eden Splash ekranı
@RoutePage()
/// Uygulama açılışında kimlik doğrulama durumunu kontrol eden Splash ekranı
final class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

final class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// Token kontrolü, gerekirse yenileme ve uygun rotaya yönlendirme yapar
  Future<void> _bootstrap() async {
    final repo = di<AuthRepository>();
    final storage = di<TokenStorage>();

    var isAuthenticated = false;

    try {
      final access = await storage.readAccessToken();
      final refresh = await storage.readRefreshToken();

      if (access == null && refresh != null) {
        // Access yoksa yenileme dene
        isAuthenticated = await repo.refresh();
      }

      if (!isAuthenticated) {
        // Access varsa me çağrısı dene
        try {
          await repo.me();
          isAuthenticated = true;
        } on DioException catch (e) {
          if (e.response?.statusCode == 401 && refresh != null) {
            // 401 olursa refresh dene
            isAuthenticated = await repo.refresh();
            if (isAuthenticated) {
              await repo.me();
            }
          }
        }
      }
    } on Exception {
      isAuthenticated = false;
    }

    if (!mounted) return;

    if (isAuthenticated) {
      await context.router.replace(const HomeRoute());
    } else {
      await context.router.replace(const LoginRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, size: 96, color: scheme.primaryContainer.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text(
              'Cozum',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.9),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yükleniyor...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(color: scheme.onPrimary.withValues(alpha: 0.1)),
          ],
        ),
      ),
    );
  }
}