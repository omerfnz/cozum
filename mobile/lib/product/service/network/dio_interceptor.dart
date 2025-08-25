import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../storage/storage_service.dart';
import '../../constants/api_endpoints.dart';


/// Authentication interceptor for automatic token handling
final class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required IStorageService storageService,
    required Logger logger,
  })  : _storageService = storageService,
        _logger = logger;

  final IStorageService _storageService;
  final Logger _logger;
  
  // Track if we're currently refreshing to avoid multiple refresh calls
  bool _isRefreshing = false;
  final List<RequestOptions> _failedQueue = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Skip auth for login/register/refresh endpoints
      if (_isAuthEndpoint(options.path)) {
        return handler.next(options);
      }

      final accessToken = await _storageService.getAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }

      handler.next(options);
    } catch (e) {
      _logger.e('Auth interceptor request error: $e');
      handler.next(options);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      // Handle 401 Unauthorized errors
      if (err.response?.statusCode == 401 && !_isAuthEndpoint(err.requestOptions.path)) {
        if (_isRefreshing) {
          // If refresh is in progress, queue the request
          _failedQueue.add(err.requestOptions);
          return;
        }

        _isRefreshing = true;
        
        try {
          final refreshToken = await _storageService.getRefreshToken();
          if (refreshToken == null) {
            // No refresh token, redirect to login
            await _storageService.clearTokens();
            return handler.next(err);
          }

          // Attempt to refresh the token
          final dio = Dio();
          dio.options.baseUrl = err.requestOptions.baseUrl;
          
          final response = await dio.post(
            ApiEndpoints.refresh,
            data: {'refresh': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['access'] as String?;
            final newRefreshToken = response.data['refresh'] as String?;

            if (newAccessToken != null) {
              await _storageService.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken ?? refreshToken,
              );

              // Retry the original request with new token
              final clonedRequest = await _cloneRequest(err.requestOptions);
              clonedRequest.headers['Authorization'] = 'Bearer $newAccessToken';
              
              final retryResponse = await dio.fetch(clonedRequest);
              
              // Process queued requests
              await _processFailedQueue(newAccessToken);
              
              return handler.resolve(retryResponse);
            }
          }
        } on DioException catch (refreshError) {
          _logger.e('Token refresh failed: $refreshError');
          await _storageService.clearTokens();
          await _rejectFailedQueue();
        } finally {
          _isRefreshing = false;
        }
      }

      handler.next(err);
    } catch (e) {
      _logger.e('Auth interceptor error handling failed: $e');
      _isRefreshing = false;
      handler.next(err);
    }
  }

  bool _isAuthEndpoint(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return normalized.startsWith(ApiEndpoints.login) || 
           normalized.startsWith(ApiEndpoints.register) || 
           normalized.startsWith(ApiEndpoints.refresh);
  }

  Future<RequestOptions> _cloneRequest(RequestOptions request) async {
    return RequestOptions(
      method: request.method,
      path: request.path,
      baseUrl: request.baseUrl,
      data: request.data,
      queryParameters: request.queryParameters,
      headers: Map<String, dynamic>.from(request.headers),
      connectTimeout: request.connectTimeout,
      receiveTimeout: request.receiveTimeout,
      sendTimeout: request.sendTimeout,
    );
  }

  Future<void> _processFailedQueue(String newAccessToken) async {
    for (final requestOptions in _failedQueue) {
      try {
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final dio = Dio();
        dio.options.baseUrl = requestOptions.baseUrl;
        await dio.fetch(requestOptions);
      } catch (e) {
        _logger.e('Failed to retry queued request: $e');
      }
    }
    _failedQueue.clear();
  }

  Future<void> _rejectFailedQueue() async {
    _failedQueue.clear();
  }
}

/// Error handling interceptor for better error management
final class ErrorInterceptor extends Interceptor {
  ErrorInterceptor({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'Unknown error occurred';
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleBadResponse(err);
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Connection error. Please check your internet connection.';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'An unexpected error occurred. Please try again.';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Certificate error. Please check your connection security.';
        break;
    }

    _logger.e('Network Error: $errorMessage', error: err);
    
    // Create a new DioException with user-friendly message
    final customError = DioException(
      requestOptions: err.requestOptions,
      type: err.type,
      error: err.error,
      response: err.response,
      message: errorMessage,
    );
    
    handler.next(customError);
  }

  String _handleBadResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final responseData = err.response?.data;

    // Ortak alanlardan mesaj çekme (DRF: detail/message/errors)
    String? extractMessage(dynamic data) {
      if (data == null) return null;
      if (data is String) return data.isNotEmpty ? data : null;
      if (data is Map) {
        final dynamic message = data['message'] ?? data['detail'] ?? data['error'];
        if (message is String && message.isNotEmpty) return message;
        // errors alanı: {field: ["msg1", "msg2"]} veya {"non_field_errors": ["..."]}
        final dynamic errors = data['errors'] ?? data['non_field_errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            final firstMsg = first.first;
            if (firstMsg is String && firstMsg.isNotEmpty) return firstMsg;
            return firstMsg?.toString();
          }
          return first?.toString();
        }
        // Alan bazlı hatalar doğrudan map olarak gelebilir
        // Örn: {"email": ["Bu alan zorunludur."]}
        for (final entry in data.entries) {
          final v = entry.value;
          if (v is List && v.isNotEmpty) {
            final firstMsg = v.first;
            if (firstMsg is String && firstMsg.isNotEmpty) return firstMsg;
            return firstMsg?.toString();
          }
        }
      }
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        return first is String ? first : first?.toString();
      }
      return data.toString();
    }

    switch (statusCode) {
      case 400:
        final msg = extractMessage(responseData);
        return msg ?? 'Bad request. Please check your input.';
      case 401:
        return 'Authentication failed. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission to perform this action.';
      case 404:
        return 'Resource not found.';
      case 422:
        final msg = extractMessage(responseData);
        return msg ?? 'Validation error. Please check your input.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        final msg = extractMessage(responseData);
        return msg ?? 'Server error ($statusCode). Please try again later.';
    }
  }
}