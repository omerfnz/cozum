import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/theme/theme.dart' as core_theme;
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/navigation/app_router.dart';
import 'package:oktoast/oktoast.dart';

/// Uygulama giriş noktası
Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // API_BASE_URL build-time ile gelebilir; Android'de localhost/127.0.0.1 kullanımı emulator için 10.0.2.2'ye çevrilir
  const rawBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.ntek.com.tr/api/',
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
    return BlocProvider(
      create: (context) => core_theme.ThemeCubit(const FlutterSecureStorage())..loadTheme(),
      child: BlocBuilder<core_theme.ThemeCubit, core_theme.ThemeState>(
        builder: (context, themeState) {
          // Sistem tema değişikliklerini dinle
          final brightness = MediaQuery.platformBrightnessOf(context);
          final isSystemDark = brightness == Brightness.dark;
          
          // Sistem tema durumunu güncelle
          if (themeState.isSystemDark != isSystemDark) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
               context.read<core_theme.ThemeCubit>().updateSystemTheme(isSystemDark);
             });
          }
          
          // Sistem UI overlay stilini güncelle
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: themeState.isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness: themeState.isDark ? Brightness.dark : Brightness.light,
              systemNavigationBarColor: themeState.isDark 
                   ? core_theme.AppTheme.darkTheme.colorScheme.surface
                   : core_theme.AppTheme.lightTheme.colorScheme.surface,
              systemNavigationBarIconBrightness: themeState.isDark ? Brightness.light : Brightness.dark,
            ),
          );
          
          return OKToast(
            position: ToastPosition.bottom,
            dismissOtherOnShow: true,
            backgroundColor: const Color(0xFF000000).withValues(alpha: 0.85),
            radius: 8,
            textStyle: const TextStyle(color: Colors.white),
            child: MaterialApp.router(
              title: 'Cozum Var',
              theme: core_theme.AppTheme.lightTheme,
               darkTheme: core_theme.AppTheme.darkTheme,
              themeMode: _getFlutterThemeMode(themeState.themeMode),
              routerConfig: di<AppRouter>().config(),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
  
  /// Tema modunu Flutter ThemeMode'a çevir
  ThemeMode _getFlutterThemeMode(core_theme.ThemeMode themeMode) {
    switch (themeMode) {
      case core_theme.ThemeMode.light:
        return ThemeMode.light;
      case core_theme.ThemeMode.dark:
        return ThemeMode.dark;
      case core_theme.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}
