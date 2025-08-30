/// Configuration for network request retry mechanism
final class RetryConfig {
  /// Number of retry attempts (default: 3)
  final int maxRetries;
  
  /// Initial delay between retries in milliseconds (default: 1000ms)
  final int initialDelayMs;
  
  /// Whether to use exponential backoff (default: true)
  final bool useExponentialBackoff;
  
  /// Maximum delay between retries in milliseconds (default: 10000ms)
  final int maxDelayMs;
  
  /// Whether to add jitter to delay (default: true)
  final bool useJitter;
  
  /// List of HTTP status codes that should trigger a retry
  final List<int> retryableStatusCodes;
  
  /// Whether to retry on timeout exceptions (default: true)
  final bool retryOnTimeout;
  
  /// Whether to retry on connection errors (default: true)
  final bool retryOnConnectionError;
  
  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelayMs = 1000,
    this.useExponentialBackoff = true,
    this.maxDelayMs = 10000,
    this.useJitter = true,
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.retryOnTimeout = true,
    this.retryOnConnectionError = true,
  });
  
  /// Default retry configuration
  static const RetryConfig defaultConfig = RetryConfig();
  
  /// No retry configuration
  static const RetryConfig noRetry = RetryConfig(maxRetries: 0);
  
  /// Aggressive retry configuration for critical requests
  static const RetryConfig aggressive = RetryConfig(
    maxRetries: 5,
    initialDelayMs: 500,
    maxDelayMs: 15000,
  );
  
  /// Conservative retry configuration for non-critical requests
  static const RetryConfig conservative = RetryConfig(
    maxRetries: 2,
    initialDelayMs: 2000,
    maxDelayMs: 5000,
  );
  
  @override
  String toString() {
    return 'RetryConfig('
        'maxRetries: $maxRetries, '
        'initialDelayMs: $initialDelayMs, '
        'useExponentialBackoff: $useExponentialBackoff, '
        'maxDelayMs: $maxDelayMs, '
        'useJitter: $useJitter, '
        'retryableStatusCodes: $retryableStatusCodes, '
        'retryOnTimeout: $retryOnTimeout, '
        'retryOnConnectionError: $retryOnConnectionError'
        ')';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is RetryConfig &&
        other.maxRetries == maxRetries &&
        other.initialDelayMs == initialDelayMs &&
        other.useExponentialBackoff == useExponentialBackoff &&
        other.maxDelayMs == maxDelayMs &&
        other.useJitter == useJitter &&
        _listEquals(other.retryableStatusCodes, retryableStatusCodes) &&
        other.retryOnTimeout == retryOnTimeout &&
        other.retryOnConnectionError == retryOnConnectionError;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      maxRetries,
      initialDelayMs,
      useExponentialBackoff,
      maxDelayMs,
      useJitter,
      Object.hashAll(retryableStatusCodes),
      retryOnTimeout,
      retryOnConnectionError,
    );
  }
  
  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}