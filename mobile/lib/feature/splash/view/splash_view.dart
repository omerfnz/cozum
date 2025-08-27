import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../product/init/service_locator.dart';
import '../../../product/service/auth/auth_service.dart';
import '../../../product/navigation/app_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _decideNavigation();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _decideNavigation() async {
    final router = context.router;
    bool isLoggedIn = false;
    try {
      final authService = serviceLocator<IAuthService>();
      isLoggedIn = await authService.isLoggedIn();

      if (isLoggedIn) {
        final me = await authService
            .getCurrentUser()
            .timeout(const Duration(seconds: 12));
        if (me.isSuccess && me.data != null) {
          if (!mounted) return;
          router.replaceAll([const HomeViewRoute()]);
          return;
        } else {
          await authService.logout();
          if (!mounted) return;
          router.replaceAll([const LoginViewRoute()]);
          return;
        }
      }
    } on TimeoutException {
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1976D2),
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'asset/icons/logo.svg',
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Çözüm Var',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yükleniyor...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}