import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';

/// Cache service interface
abstract class ICacheService {
  /// Initialize the cache service
  Future<void> initialize();
  
  /// Store data in cache
  Future<void> store<T>(String key, T data, {Duration? expiry});
  
  /// Retrieve data from cache
  Future<T?> retrieve<T>(String key);
  
  /// Check if data exists and is not expired
  Future<bool> exists(String key);
  
  /// Clear specific cache entry
  Future<void> clear(String key);
  
  /// Clear all cache
  Future<void> clearAll();
  
  /// Get cache size
  Future<int> getCacheSize();
  
  /// Dispose resources
  Future<void> dispose();
}

/// Cache entry model
class CacheEntry {
  const CacheEntry({
    required this.data,
    required this.timestamp,
    this.expiry,
  });
  
  final String data;
  final DateTime timestamp;
  final DateTime? expiry;
  
  bool get isExpired {
    if (expiry == null) return false;
    return DateTime.now().isAfter(expiry!);
  }
  
  Map<String, dynamic> toJson() => {
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'expiry': expiry?.toIso8601String(),
  };
  
  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
    data: json['data'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    expiry: json['expiry'] != null ? DateTime.parse(json['expiry'] as String) : null,
  );
}

/// Hive-based cache service implementation
final class CacheService implements ICacheService {
  CacheService();
  
  final Logger _logger = GetIt.I<Logger>();
  Box<String>? _cacheBox;
  bool _isInitialized = false;
  
  static const String _boxName = 'app_cache';
  
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _logger.i('Initializing cache service');
      
      // Initialize Hive if not already initialized
      if (!Hive.isAdapterRegistered(0)) {
        await Hive.initFlutter();
      }
      
      // Open cache box
      _cacheBox = await Hive.openBox<String>(_boxName);
      
      // Clean expired entries on startup
      await _cleanExpiredEntries();
      
      _isInitialized = true;
      _logger.i('Cache service initialized with ${_cacheBox?.length ?? 0} entries');
    } catch (e) {
      _logger.e('Failed to initialize cache service: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> store<T>(String key, T data, {Duration? expiry}) async {
    _ensureInitialized();
    
    try {
      final jsonData = jsonEncode(data);
      final entry = CacheEntry(
        data: jsonData,
        timestamp: DateTime.now(),
        expiry: expiry != null ? DateTime.now().add(expiry) : null,
      );
      
      await _cacheBox!.put(key, jsonEncode(entry.toJson()));
      _logger.d('Cached data for key: $key');
    } catch (e) {
      _logger.e('Failed to store cache for key $key: $e');
      rethrow;
    }
  }
  
  @override
  Future<T?> retrieve<T>(String key) async {
    _ensureInitialized();
    
    try {
      final cachedData = _cacheBox!.get(key);
      if (cachedData == null) return null;
      
      final entryJson = jsonDecode(cachedData) as Map<String, dynamic>;
      final entry = CacheEntry.fromJson(entryJson);
      
      // Check if expired
      if (entry.isExpired) {
        await _cacheBox!.delete(key);
        _logger.d('Removed expired cache for key: $key');
        return null;
      }
      
      final data = jsonDecode(entry.data);
      _logger.d('Retrieved cache for key: $key');
      return data as T;
    } catch (e) {
      _logger.e('Failed to retrieve cache for key $key: $e');
      return null;
    }
  }
  
  @override
  Future<bool> exists(String key) async {
    _ensureInitialized();
    
    try {
      final cachedData = _cacheBox!.get(key);
      if (cachedData == null) return false;
      
      final entryJson = jsonDecode(cachedData) as Map<String, dynamic>;
      final entry = CacheEntry.fromJson(entryJson);
      
      if (entry.isExpired) {
        await _cacheBox!.delete(key);
        return false;
      }
      
      return true;
    } catch (e) {
      _logger.e('Failed to check cache existence for key $key: $e');
      return false;
    }
  }
  
  @override
  Future<void> clear(String key) async {
    _ensureInitialized();
    
    try {
      await _cacheBox!.delete(key);
      _logger.d('Cleared cache for key: $key');
    } catch (e) {
      _logger.e('Failed to clear cache for key $key: $e');
    }
  }
  
  @override
  Future<void> clearAll() async {
    _ensureInitialized();
    
    try {
      await _cacheBox!.clear();
      _logger.i('Cleared all cache');
    } catch (e) {
      _logger.e('Failed to clear all cache: $e');
    }
  }
  
  @override
  Future<int> getCacheSize() async {
    _ensureInitialized();
    return _cacheBox?.length ?? 0;
  }
  
  @override
  Future<void> dispose() async {
    try {
      await _cacheBox?.close();
      _isInitialized = false;
      _logger.i('Cache service disposed');
    } catch (e) {
      _logger.e('Failed to dispose cache service: $e');
    }
  }
  
  /// Clean expired entries from cache
  Future<void> _cleanExpiredEntries() async {
    if (_cacheBox == null) return;
    
    try {
      final keysToDelete = <String>[];
      
      for (final key in _cacheBox!.keys) {
        try {
          final cachedData = _cacheBox!.get(key);
          if (cachedData == null) continue;
          
          final entryJson = jsonDecode(cachedData) as Map<String, dynamic>;
          final entry = CacheEntry.fromJson(entryJson);
          
          if (entry.isExpired) {
            keysToDelete.add(key as String);
          }
        } catch (e) {
          // If we can't parse the entry, consider it corrupted and delete it
          keysToDelete.add(key as String);
        }
      }
      
      for (final key in keysToDelete) {
        await _cacheBox!.delete(key);
      }
      
      if (keysToDelete.isNotEmpty) {
        _logger.i('Cleaned ${keysToDelete.length} expired/corrupted cache entries');
      }
    } catch (e) {
      _logger.e('Failed to clean expired entries: $e');
    }
  }
  
  void _ensureInitialized() {
    if (!_isInitialized || _cacheBox == null) {
      throw StateError('Cache service not initialized. Call initialize() first.');
    }
  }
}

/// Cache keys for different data types
class CacheKeys {
  static const String reports = 'reports';
  static const String categories = 'categories';
  static const String teams = 'teams';
  static const String userProfile = 'user_profile';
  static const String reportDetail = 'report_detail_';
  static const String teamMembers = 'team_members_';
  static const String reportComments = 'report_comments_';
  
  // Cache durations
  static const Duration shortCache = Duration(minutes: 5);
  static const Duration mediumCache = Duration(minutes: 30);
  static const Duration longCache = Duration(hours: 2);
  static const Duration veryLongCache = Duration(hours: 24);
}