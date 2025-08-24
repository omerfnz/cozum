import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:logger/logger.dart';
import 'package:mobile/product/auth/auth_repository.dart';
import 'package:mobile/product/auth/token_storage.dart';
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/navigation/app_router.dart';
import 'package:oktoast/oktoast.dart';

/// Uygulama açılışında kimlik doğrulama durumunu kontrol eden Splash ekranı
@RoutePage()
/// Uygulama açılışında kimlik doğrulama durumunu kontrol eden Splash ekranı
final class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

final class _SplashViewState extends State<SplashView> {
  bool _animate = false;
  @override
  void initState() {
    super.initState();
    // Animasyonu tetikle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _animate = true);
      // İlk frame çizildikten sonra native splash'ı kaldır
      FlutterNativeSplash.remove();
    });
    _bootstrap();
  }

  /// Token kontrolü, gerekirse yenileme ve uygun rotaya yönlendirme yapar
  Future<void> _bootstrap() async {
    final repo = di<AuthRepository>();
    final storage = di<TokenStorage>();
    final logger = di<Logger>();

    var isAuthenticated = false;

    try {
      final access = await storage.readAccessToken();
      final refresh = await storage.readRefreshToken();
      logger.i('[Splash] access=${access != null}, refresh=${refresh != null}');

      if (access == null && refresh != null) {
        // Access yoksa yenileme dene
        logger.i('[Splash] Access yok, refresh deneniyor');
        isAuthenticated = await repo.refresh();
        logger.i('[Splash] Refresh sonucu: $isAuthenticated');
      }

      if (!isAuthenticated) {
        // Access varsa me çağrısı dene
        try {
          logger.i('[Splash] /auth/me çağrılıyor');
          await repo.me();
          isAuthenticated = true;
          logger.i('[Splash] /auth/me başarılı');
        } on DioException catch (e) {
          logger.w('[Splash] /auth/me hata: ${e.message} code=${e.response?.statusCode}');
          if (e.response?.statusCode == 401 && refresh != null) {
            // 401 olursa refresh dene
            logger.i('[Splash] 401 -> refresh deneniyor');
            isAuthenticated = await repo.refresh();
            logger.i('[Splash] Refresh sonucu: $isAuthenticated');
            if (isAuthenticated) {
              await repo.me();
            }
          } else if (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.unknown) {
            showToast('Sunucuya bağlanılamadı. Lütfen ağ ve API_BASE_URL ayarını kontrol edin.');
          }
        }
      }
    } on Exception catch (e) {
      logger.e('[Splash] Başlatma hatası: $e');
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
            AnimatedScale(
              scale: _animate ? 1.0 : 0.85,
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: _animate ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                child: Icon(Icons.bolt, size: 96, color: scheme.primaryContainer.withValues(alpha: 0.7)),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: _animate ? 1 : 0,
              duration: const Duration(milliseconds: 700),
              child: Text(
                'Cozum',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: scheme.onPrimary.withValues(alpha: 0.9),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedOpacity(
              opacity: _animate ? 1 : 0,
              duration: const Duration(milliseconds: 800),
              child: Text(
                'Yükleniyor...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimary.withValues(alpha: 0.7),
                    ),
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