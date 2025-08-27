import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

/// Global error handler for the application
final class GlobalErrorHandler {
  GlobalErrorHandler._();
  
  static final GlobalErrorHandler _instance = GlobalErrorHandler._();
  static GlobalErrorHandler get instance => _instance;
  
  late final Logger _logger;
  
  /// Initialize the global error handler
  void initialize(Logger logger) {
    _logger = logger;
    
    // Setup Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      handleFlutterError(details);
    };
    
    // Setup platform dispatcher error handling for async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      handlePlatformError(error, stack);
      return true;
    };
  }
  
  /// Handle Flutter framework errors
  void handleFlutterError(FlutterErrorDetails details) {
    _logger.e(
      'Flutter Error: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
    );
    
    if (kDebugMode) {
      // Show detailed error in debug mode
      FlutterError.presentError(details);
    } else {
      // Log to crash analytics in production
      // TODO: Integrate with crash analytics service (Firebase Crashlytics, Sentry, etc.)
      _showUserFriendlyError('Beklenmeyen bir hata oluştu');
    }
  }
  
  /// Handle platform/async errors
  void handlePlatformError(Object error, StackTrace stack) {
    _logger.e(
      'Platform Error: $error',
      error: error,
      stackTrace: stack,
    );
    
    if (kDebugMode) {
      debugPrint('Platform Error: $error\nStack: $stack');
    } else {
      // TODO: Log to crash analytics
      _showUserFriendlyError('Sistem hatası oluştu');
    }
  }
  
  /// Handle network errors from Dio
  String handleNetworkError(DioException error) {
    String userMessage;
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        userMessage = 'Bağlantı zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.';
        break;
      case DioExceptionType.sendTimeout:
        userMessage = 'Veri gönderme zaman aşımına uğradı. Tekrar deneyin.';
        break;
      case DioExceptionType.receiveTimeout:
        userMessage = 'Veri alma zaman aşımına uğradı. Tekrar deneyin.';
        break;
      case DioExceptionType.badResponse:
        userMessage = _handleBadResponse(error);
        break;
      case DioExceptionType.cancel:
        userMessage = 'İstek iptal edildi.';
        break;
      case DioExceptionType.connectionError:
        userMessage = 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.';
        break;
      case DioExceptionType.badCertificate:
        userMessage = 'Güvenlik sertifikası hatası.';
        break;
      case DioExceptionType.unknown:
        userMessage = 'Beklenmeyen bir ağ hatası oluştu.';
        break;
    }
    
    _logger.e(
      'Network Error: ${error.type} - ${error.message}',
      error: error,
      stackTrace: error.stackTrace,
    );
    
    return userMessage;
  }
  
  /// Handle bad HTTP responses
  String _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    
    // Try to extract user-friendly message from response
    String? extractMessage(dynamic data) {
      if (data == null) return null;
      if (data is String) return data.isNotEmpty ? data : null;
      if (data is Map) {
        final dynamic message = data['message'] ?? data['detail'] ?? data['error'];
        if (message is String && message.isNotEmpty) return message;
        
        // Handle field errors
        final dynamic errors = data['errors'] ?? data['non_field_errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            final firstMsg = first.first;
            return firstMsg is String ? firstMsg : firstMsg?.toString();
          }
          return first?.toString();
        }
        
        // Handle direct field errors
        for (final entry in data.entries) {
          final v = entry.value;
          if (v is List && v.isNotEmpty) {
            final firstMsg = v.first;
            return firstMsg is String ? firstMsg : firstMsg?.toString();
          }
        }
      }
      return null;
    }
    
    switch (statusCode) {
      case 400:
        return extractMessage(responseData) ?? 'Geçersiz istek. Girdiğiniz bilgileri kontrol edin.';
      case 401:
        return 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.';
      case 403:
        return 'Bu işlem için yetkiniz bulunmuyor.';
      case 404:
        return 'Aranan kaynak bulunamadı.';
      case 422:
        return extractMessage(responseData) ?? 'Doğrulama hatası. Girdiğiniz bilgileri kontrol edin.';
      case 429:
        return 'Çok fazla istek gönderildi. Lütfen bekleyin.';
      case 500:
        return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
      case 502:
        return 'Sunucu geçici olarak erişilemez durumda.';
      case 503:
        return 'Servis geçici olarak kullanılamıyor.';
      default:
        return extractMessage(responseData) ?? 'Sunucu hatası ($statusCode). Lütfen daha sonra tekrar deneyin.';
    }
  }
  
  /// Handle general application errors
  void handleAppError(Object error, StackTrace? stackTrace, {String? context}) {
    final contextInfo = context != null ? ' Context: $context' : '';
    
    _logger.e(
      'App Error:$contextInfo $error',
      error: error,
      stackTrace: stackTrace,
    );
    
    String userMessage;
    
    if (error is DioException) {
      userMessage = handleNetworkError(error);
    } else if (error is FormatException) {
      userMessage = 'Veri formatı hatası oluştu.';
    } else if (error is TimeoutException) {
      userMessage = 'İşlem zaman aşımına uğradı.';
    } else {
      userMessage = kDebugMode 
          ? 'Hata: ${error.toString()}'
          : 'Beklenmeyen bir hata oluştu.';
    }
    
    _showUserFriendlyError(userMessage);
  }
  
  /// Show user-friendly error message
  void _showUserFriendlyError(String message) {
    // Error messages will be handled by the UI layer
    // This method is kept for compatibility but doesn't show UI
    _logger.w('User-friendly error: $message');
  }
  
  /// Show success message
  void showSuccess(String message) {
    _logger.i('Success: $message');
  }
  
  /// Show info message
  void showInfo(String message) {
    _logger.i('Info: $message');
  }
  
  /// Show warning message
  void showWarning(String message) {
    _logger.w('Warning: $message');
  }
}

/// Extension for easy error handling in widgets
extension ErrorHandlingExtension on Object {
  /// Handle error with optional context
  void handleError([String? context]) {
    GlobalErrorHandler.instance.handleAppError(
      this,
      StackTrace.current,
      context: context,
    );
  }
}

/// Mixin for widgets that need error handling
mixin ErrorHandlingMixin {
  /// Handle error safely
  void handleError(Object error, [String? context]) {
    GlobalErrorHandler.instance.handleAppError(
      error,
      StackTrace.current,
      context: context,
    );
  }
  
  /// Show success message
  void showSuccess(String message) {
    GlobalErrorHandler.instance.showSuccess(message);
  }
  
  /// Show error message
  void showError(String message) {
    GlobalErrorHandler.instance._showUserFriendlyError(message);
  }
  
  /// Show info message
  void showInfo(String message) {
    GlobalErrorHandler.instance.showInfo(message);
  }
  
  /// Show warning message
  void showWarning(String message) {
    GlobalErrorHandler.instance.showWarning(message);
  }
}