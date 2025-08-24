import 'package:dio/dio.dart';

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

/// Network service interface
abstract class INetworkService {
  Future<NetworkResponse<T>> request<T>({
    required String path,
    required RequestType type,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  });
  
  Future<NetworkResponse<T>> uploadFile<T>({
    required String path,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
    ProgressCallback? onSendProgress,
  });
}

/// Network service implementation with Dio
final class NetworkService implements INetworkService {
  NetworkService(this._dio);
  
  final Dio _dio;
  // final Logger _logger = serviceLocator<Logger>();
  
  @override
  Future<NetworkResponse<T>> request<T>({
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
      
      switch (type) {
        case RequestType.get:
          response = await _dio.get(
            path,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case RequestType.post:
          response = await _dio.post(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case RequestType.put:
          response = await _dio.put(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case RequestType.patch:
          response = await _dio.patch(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case RequestType.delete:
          response = await _dio.delete(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
      }
      
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
      
    } on DioException catch (e) {
      return NetworkResponse<T>(
        data: null,
        statusCode: e.response?.statusCode ?? 0,
        error: e.message ?? 'Network error occurred',
      );
    } catch (e) {
      return NetworkResponse<T>(
        data: null,
        statusCode: 0,
        error: e.toString(),
      );
    }
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
  
  @override
  Future<NetworkResponse<T>> uploadFile<T>({
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
      
      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
      );
      
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
      
    } on DioException catch (e) {
      return NetworkResponse<T>(
        data: null,
        statusCode: e.response?.statusCode ?? 0,
        error: e.message ?? 'Upload failed',
      );
    } catch (e) {
      return NetworkResponse<T>(
        data: null,
        statusCode: 0,
        error: e.toString(),
      );
    }
  }
}