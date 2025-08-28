import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'service_locator.dart';
import '../service/error/global_error_handler.dart';

/// Application initialization class
final class ApplicationInitialize {
  /// Initialize the application
  Future<void> make() async {
    // Splash ekranını, başlatma tamamlanana kadar koru
    final binding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: binding);

    // Initialize EasyLocalization
    await EasyLocalization.ensureInitialized();

    // Setup dependency injection
    await setupServiceLocator();

    // Setup global error handling
    final logger = GetIt.I<Logger>();
    GlobalErrorHandler.instance.initialize(logger);

    // Başlatma işlemleri tamamlandı, splash ekranını kaldır
    FlutterNativeSplash.remove();
  }
}