import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:math';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';
import '../connectivity/connectivity_service.dart';
import '../cache/cache_service.dart';

/// HTTP request types
enum RequestType { get, post, put, patch, delete }

/// Network response model
final class NetworkResponse<T> {
  const NetworkResponse({
    required this.data,
    required this.statusCode,
    this.message,
    this.error,
  });
  
  final T? data;
  final int statusCode;
  final String? message;
  final String? error;
  
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Retry configuration
final class RetryConfig {
  const RetryConfig({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 10),
    this.retryableStatusCodes = const {408, 429, 500, 502, 503, 504},
  });
  
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;
  final Set<int> retryableStatusCodes;
}

/// Network service interface
abstract class INetworkService {
  Future<NetworkResponse<T>> request<T>({
    required String path,
    required RequestType type,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
    RetryConfig? retryConfig,
    bool useCache = true,
    Duration? cacheExpiry,
  });
  
  Future<NetworkResponse<T>> uploadFile<T>({
    required String path,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
    ProgressCallback? onSendProgress,
    RetryConfig? retryConfig,
  });
}

/// Network service implementation with retry mechanism and offline support
final class NetworkService implements INetworkService {
  NetworkService(this._dio);
  
  final Dio _dio;
  final Logger _logger = GetIt.I<Logger>();
  final IConnectivityService _connectivityService = GetIt.I<IConnectivityService>();
  final ICacheService _cacheService = GetIt.I<ICacheService>();
  final RetryConfig _defaultRetryConfig = const RetryConfig();
  
  @override
  Future<NetworkResponse<T>> request<T>({
    required String path,
    required RequestType type,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
    RetryConfig? retryConfig,
    bool useCache = true,
    Duration? cacheExpiry,
  }) async {
    final config = retryConfig ?? _defaultRetryConfig;
    final cacheKey = _generateCacheKey(path, queryParameters);
    
    // Check connectivity status
    final isConnected = await _connectivityService.isConnected;
    
    // If offline and cache is enabled, try to return cached data
    if (!isConnected && useCache && type == RequestType.get) {
      final cachedData = await _cacheService.retrieve<T>(cacheKey);
      if (cachedData != null) {
        _logger.i('Returning cached data for offline request: $path');
        return NetworkResponse<T>(
          data: cachedData,
          statusCode: 200,
          message: 'Cached data (offline)',
        );
      } else {
        return NetworkResponse<T>(
          data: null,
          statusCode: 0,
          error: 'No internet connection and no cached data available',
        );
      }
    }
    
    // If online, try network request with retry mechanism
    for (int attempt = 0; attempt <= config.maxRetries; attempt++) {
      try {
        final response = await _executeRequest<T>(
          path: path,
          type: type,
          data: data,
          queryParameters: queryParameters,
          headers: headers,
          parser: parser,
        );
        
        // Cache successful GET requests
        if (response.isSuccess && useCache && type == RequestType.get && response.data != null) {
          final expiry = cacheExpiry ?? const Duration(minutes: 30);
          await _cacheService.store(cacheKey, response.data, expiry: expiry);
          _logger.d('Cached response for: $path');
        }
        
        return response;
      } catch (e) {
        // If this is the last attempt and we have cached data, return it
        if (attempt == config.maxRetries && useCache && type == RequestType.get) {
          final cachedData = await _cacheService.retrieve<T>(cacheKey);
          if (cachedData != null) {
            _logger.w('Network failed, returning cached data for: $path');
            return NetworkResponse<T>(
              data: cachedData,
              statusCode: 200,
              message: 'Cached data (network failed)',
            );
          }
        }
        
        if (attempt == config.maxRetries || !_shouldRetry(e, config)) {
          rethrow;
        }
        
        final delay = _calculateDelay(attempt, config);
        _logger.w('Request failed (attempt ${attempt + 1}/${config.maxRetries + 1}), retrying in ${delay.inMilliseconds}ms: $e');
        await Future.delayed(delay);
      }
    }
    
    throw Exception('Max retries exceeded');
  }
  
  Future<NetworkResponse<T>> _executeRequest<T>({
    required String path,
    required RequestType type,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) async {
    try {
      final options = Options(
        headers: headers,
        method: _getMethod(type),
      );
      
      Response response;
      
      Future<Response> exec() async {
        switch (type) {
          case RequestType.get:
            return _dio.get(
              path,
              queryParameters: queryParameters,
              options: options,
            );
          case RequestType.post:
            return _dio.post(
              path,
              data: data,
              queryParameters: queryParameters,
              options: options,
            );
          case RequestType.put:
            return _dio.put(
              path,
              data: data,
              queryParameters: queryParameters,
              options: options,
            );
          case RequestType.patch:
            return _dio.patch(
              path,
              data: data,
              queryParameters: queryParameters,
              options: options,
            );
          case RequestType.delete:
            return _dio.delete(
              path,
              data: data,
              queryParameters: queryParameters,
              options: options,
            );
        }
      }
      
      response = await exec().timeout(const Duration(seconds: 25));
      
      T? parsedData;
      if (parser != null && response.data != null) {
        parsedData = parser(response.data);
      } else {
        parsedData = response.data as T?;
      }
      
      return NetworkResponse<T>(
        data: parsedData,
        statusCode: response.statusCode ?? 0,
        message: 'Success',
      );
      
    } on TimeoutException catch (e) {
      _logger.e('Request timeout: $path', error: e);
      throw NetworkResponse<T>(
        data: null,
        statusCode: 0,
        error: 'Request timed out. Please try again.',
      );
    } on DioException catch (e) {
      _logger.e('Dio error: $path', error: e);
      throw NetworkResponse<T>(
        data: null,
        statusCode: e.response?.statusCode ?? 0,
        error: e.message ?? 'Network error occurred',
      );
    } catch (e) {
      _logger.e('Unexpected error: $path', error: e);
      throw NetworkResponse<T>(
        data: null,
        statusCode: 0,
        error: e.toString(),
      );
    }
  }
  
  /// Check if the error should trigger a retry
  bool _shouldRetry(Object error, RetryConfig config) {
    if (error is NetworkResponse) {
      return config.retryableStatusCodes.contains(error.statusCode);
    }
    if (error is DioException) {
      // Retry on connection errors, timeouts, and specific status codes
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return true;
        case DioExceptionType.badResponse:
          return config.retryableStatusCodes.contains(error.response?.statusCode);
        default:
          return false;
      }
    }
    if (error is TimeoutException) {
      return true;
    }
    return false;
  }
  
  /// Calculate exponential backoff delay
  Duration _calculateDelay(int attempt, RetryConfig config) {
    final exponentialDelay = config.baseDelay * pow(2, attempt);
    final jitteredDelay = exponentialDelay * (0.5 + Random().nextDouble() * 0.5);
    return Duration(
      milliseconds: min(
        jitteredDelay.inMilliseconds,
        config.maxDelay.inMilliseconds,
      ),
    );
  }
  
  String _getMethod(RequestType type) {
    switch (type) {
      case RequestType.get:
        return 'GET';
      case RequestType.post:
        return 'POST';
      case RequestType.put:
        return 'PUT';
      case RequestType.patch:
        return 'PATCH';
      case RequestType.delete:
        return 'DELETE';
    }
  }
  
  /// Generate cache key for request
  String _generateCacheKey(String path, Map<String, dynamic>? queryParameters) {
    final buffer = StringBuffer(path);
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final sortedKeys = queryParameters.keys.toList()..sort();
      buffer.write('?');
      for (int i = 0; i < sortedKeys.length; i++) {
        if (i > 0) buffer.write('&');
        buffer.write('${sortedKeys[i]}=${queryParameters[sortedKeys[i]]}');
      }
    }
    return buffer.toString();
  }
  
  @override
  Future<NetworkResponse<T>> uploadFile<T>({
    required String path,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
    ProgressCallback? onSendProgress,
    RetryConfig? retryConfig,
  }) async {
    final config = retryConfig ?? _defaultRetryConfig;
    
    for (int attempt = 0; attempt <= config.maxRetries; attempt++) {
      try {
        return await _executeUpload<T>(
          path: path,
          formData: formData,
          queryParameters: queryParameters,
          headers: headers,
          parser: parser,
          onSendProgress: onSendProgress,
        );
      } catch (e) {
        if (attempt == config.maxRetries || !_shouldRetry(e, config)) {
          rethrow;
        }
        
        final delay = _calculateDelay(attempt, config);
        _logger.w('Upload failed (attempt ${attempt + 1}/${config.maxRetries + 1}), retrying in ${delay.inMilliseconds}ms: $e');
        await Future.delayed(delay);
      }
    }
    
    throw Exception('Max upload retries exceeded');
  }
  
  Future<NetworkResponse<T>> _executeUpload<T>({
    required String path,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final options = Options(
        headers: headers,
        method: 'POST',
      );
      
      final response = await _dio
          .post(
            path,
            data: formData,
            queryParameters: queryParameters,
            options: options,
            onSendProgress: onSendProgress,
          )
          .timeout(const Duration(seconds: 25));
      
      T? parsedData;
      if (parser != null && response.data != null) {
        parsedData = parser(response.data);
      } else {
        parsedData = response.data as T?;
      }
      
      return NetworkResponse<T>(
        data: parsedData,
        statusCode: response.statusCode ?? 0,
        message: 'Upload successful',
      );
      
    } on TimeoutException catch (e) {
      _logger.e('Upload timeout: $path', error: e);
      throw NetworkResponse<T>(
        data: null,
        statusCode: 0,
        error: 'Upload timed out. Please try again.',
      );
    } on DioException catch (e) {
      _logger.e('Upload dio error: $path', error: e);
      throw NetworkResponse<T>(
        data: null,
        statusCode: e.response?.statusCode ?? 0,
        error: e.message ?? 'Upload failed',
      );
    } catch (e) {
      _logger.e('Upload unexpected error: $path', error: e);
      throw NetworkResponse<T>(
        data: null,
        statusCode: 0,
        error: e.toString(),
      );
    }
  }
}