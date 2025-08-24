import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'service_locator.dart';

/// Application initialization class
final class ApplicationInitialize {
  /// Initialize the application
  Future<void> make() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize EasyLocalization
    await EasyLocalization.ensureInitialized();
    
    // Setup dependency injection
    await setupServiceLocator();
    
    // Setup error handling
    if (kDebugMode) {
      // Development error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('Flutter Error: ${details.exception}');
        debugPrint('Stack trace: ${details.stack}');
      };
    } else {
      // Production error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        // Log to crash analytics in production
        debugPrint('Production Flutter Error: ${details.exception}');
      };
    }
  }
}