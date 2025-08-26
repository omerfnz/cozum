import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../../../product/init/service_locator.dart';
import '../../../product/service/auth/auth_service.dart';
import '../../../product/navigation/app_router.dart';

@RoutePage()
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // İlk frame’den sonra yönlendirme kararını verelim
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _decideNavigation();
    });
  }

  Future<void> _decideNavigation() async {
    final router = context.router;
    bool isLoggedIn = false;
    try {
      final authService = serviceLocator<IAuthService>();
      isLoggedIn = await authService.isLoggedIn();

      if (isLoggedIn) {
        // Token var, sunucudan kullanıcıyı doğrula
        final me = await authService
            .getCurrentUser()
            .timeout(const Duration(seconds: 12));
        if (me.isSuccess && me.data != null) {
          if (!mounted) return;
          router.replaceAll([const HomeViewRoute()]);
          return;
        } else {
          // Token geçersiz, temizle ve login’e yönlendir
          await authService.logout();
          if (!mounted) return;
          router.replaceAll([const LoginViewRoute()]);
          return;
        }
      }
    } on TimeoutException {
      // Başlangıçta uzun beklemelerde kullanıcıyı login'e al
      if (!mounted) return;
      final authService = serviceLocator<IAuthService>();
      await authService.logout();
      router.replaceAll([const LoginViewRoute()]);
      return;
    } catch (_) {
      isLoggedIn = false;
    }

     if (!mounted) return;

     if (isLoggedIn) {
       router.replaceAll([const HomeViewRoute()]);
     } else {
       router.replaceAll([const LoginViewRoute()]);
     }
   }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Çözüm Var',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'MVVM Architecture Loading...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}