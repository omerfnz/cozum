/// API endpoints for the application
final class ApiEndpoints {
  const ApiEndpoints._();
  
  // Base configurations
  static const String apiVersion = 'v1';
  
  // Health
  static const String health = 'health/';
  
  // Authentication endpoints
  static const String login = 'auth/login/';
  static const String register = 'auth/register/';
  static const String refresh = 'auth/refresh/';
  static const String me = 'auth/me/';
  static const String meUpdate = 'auth/me/update/';
  static const String passwordChange = 'auth/password/change/';
  
  // User management endpoints (admin-only CRUD)
  static const String users = 'users/';
  static String userById(int id) => 'users/$id/';
  // Special actions
  static String userSetRole(int id) => 'users/$id/set_role/';
  static String userSetTeam(int id) => 'users/$id/set_team/';
  
  // Report endpoints
  static const String reports = 'reports/';
  static String reportById(int id) => 'reports/$id/';
  static String reportComments(int id) => 'reports/$id/comments/';
  
  // Category endpoints
  static const String categories = 'categories/';
  static String categoryById(int id) => 'categories/$id/';
  
  // Team endpoints
  static const String teams = 'teams/';
  static String teamById(int id) => 'teams/$id/';
  
  // Comment endpoints (detail/update/delete)
  static String commentById(int id) => 'comments/$id/';
}

/// HTTP status codes commonly used in the application
final class HttpStatusCodes {
  const HttpStatusCodes._();
  
  static const int ok = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int noContent = 204;
  
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int tooManyRequests = 429;
  
  static const int internalServerError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;
}

/// Request content types
final class ContentTypes {
  const ContentTypes._();
  
  static const String json = 'application/json';
  static const String formData = 'multipart/form-data';
  static const String urlEncoded = 'application/x-www-form-urlencoded';
  static const String textPlain = 'text/plain';
  static const String html = 'text/html';
}

/// Common headers used in API requests
final class ApiHeaders {
  const ApiHeaders._();
  
  static const String authorization = 'Authorization';
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String userAgent = 'User-Agent';
  static const String cacheControl = 'Cache-Control';
  static const String ifModifiedSince = 'If-Modified-Since';
  static const String lastModified = 'Last-Modified';
  static const String etag = 'ETag';
  static const String ifNoneMatch = 'If-None-Match';
}