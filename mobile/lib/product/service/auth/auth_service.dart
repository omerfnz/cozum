import '../network/network_service.dart';
import '../storage/storage_service.dart';
import '../../constants/api_endpoints.dart';

/// User model for authentication
final class User {
  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    this.firstName,
    this.lastName,
    this.phone,
    this.team,
  });
  
  final int id;
  final String email;
  final String username;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final Map<String, dynamic>? team;
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      team: json['team'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'team': team,
    };
  }
}

/// Authentication tokens
final class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });
  
  final String accessToken;
  final String refreshToken;
  
  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
    );
  }
}

/// Authentication service interface
abstract class IAuthService {
  Future<NetworkResponse<AuthTokens>> login({
    required String email,
    required String password,
  });
  
  Future<NetworkResponse<User>> register({
    required String email,
    required String username,
    required String password,
  });
  
  Future<NetworkResponse<User>> getCurrentUser();
  Future<NetworkResponse<AuthTokens>> refreshToken();
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getAccessToken();
}

/// Authentication service implementation
final class AuthService implements IAuthService {
  AuthService(this._networkService, this._storageService);
  
  final INetworkService _networkService;
  final IStorageService _storageService;
  
  @override
  Future<NetworkResponse<AuthTokens>> login({
    required String email,
    required String password,
  }) async {
    final response = await _networkService.request<AuthTokens>(
      path: ApiEndpoints.login,
      type: RequestType.post,
      data: {
        'email': email,
        'password': password,
      },
      parser: (json) => AuthTokens.fromJson(json),
    );
    
    if (response.isSuccess && response.data != null) {
      final tokens = response.data!;
      // Cache + persist tek noktadan
      await _storageService.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
    }
    
    return response;
  }
  
  @override
  Future<NetworkResponse<User>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    return await _networkService.request<User>(
      path: ApiEndpoints.register,
      type: RequestType.post,
      data: {
        'email': email,
        'username': username,
        'password': password,
      },
      parser: (json) => User.fromJson(json),
    );
  }
  
  @override
  Future<NetworkResponse<User>> getCurrentUser() async {
    final token = await getAccessToken();
    if (token == null) {
      return const NetworkResponse<User>(
        data: null,
        statusCode: 401,
        error: 'No access token found',
      );
    }
    
    return await _networkService.request<User>(
      path: ApiEndpoints.me,
      type: RequestType.get,
      headers: {'Authorization': 'Bearer $token'},
      parser: (json) => User.fromJson(json),
    );
  }
  
  @override
  Future<NetworkResponse<AuthTokens>> refreshToken() async {
    final refreshToken = await _storageService.getRefreshToken();
    if (refreshToken == null) {
      return const NetworkResponse<AuthTokens>(
        data: null,
        statusCode: 401,
        error: 'No refresh token found',
      );
    }
    
    final response = await _networkService.request<AuthTokens>(
      path: ApiEndpoints.refresh,
      type: RequestType.post,
      data: {'refresh': refreshToken},
      parser: (json) => AuthTokens.fromJson(json),
    );
    
    if (response.isSuccess && response.data != null) {
      final tokens = response.data!;
      await _storageService.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
    }
    
    return response;
  }
  
  @override
  Future<void> logout() async {
    await _storageService.delete(StorageKeys.accessToken);
    await _storageService.delete(StorageKeys.refreshToken);
    await _storageService.delete(StorageKeys.userProfile);
  }
  
  @override
  Future<bool> isLoggedIn() async {
    final token = await _storageService.getAccessToken();
    return token != null;
  }
  
  @override
  Future<String?> getAccessToken() async {
    return await _storageService.getAccessToken();
  }
}