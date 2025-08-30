import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';

/// Connectivity status enum
enum ConnectivityStatus {
  connected,
  disconnected,
  unknown,
}

/// Connectivity service interface
abstract class IConnectivityService {
  /// Current connectivity status
  ConnectivityStatus get currentStatus;
  
  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get statusStream;
  
  /// Check if device is currently connected to internet
  Future<bool> get isConnected;
  
  /// Initialize the service
  Future<void> initialize();
  
  /// Dispose resources
  void dispose();
}

/// Connectivity service implementation
final class ConnectivityService implements IConnectivityService {
  ConnectivityService();
  
  final Logger _logger = GetIt.I<Logger>();
  
  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;
  final StreamController<ConnectivityStatus> _statusController = 
      StreamController<ConnectivityStatus>.broadcast();
  
  Timer? _periodicTimer;
  bool _isInitialized = false;
  
  @override
  ConnectivityStatus get currentStatus => _currentStatus;
  
  @override
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;
  
  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _logger.w('Internet connectivity check failed: $e');
      return false;
    }
  }
  
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _logger.i('Initializing connectivity service');
    
    // Initial connectivity check
    await _checkConnectivity();
    
    // Start periodic connectivity checks (every 30 seconds)
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnectivity(),
    );
    
    _isInitialized = true;
    _logger.i('Connectivity service initialized');
  }
  
  @override
  void dispose() {
    _logger.i('Disposing connectivity service');
    _periodicTimer?.cancel();
    _statusController.close();
    _isInitialized = false;
  }
  
  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final connected = await isConnected;
      final newStatus = connected 
          ? ConnectivityStatus.connected 
          : ConnectivityStatus.disconnected;
      
      if (newStatus != _currentStatus) {
        _currentStatus = newStatus;
        _statusController.add(_currentStatus);
        
        if (kDebugMode) {
          _logger.i('Connectivity status changed: ${_currentStatus.name}');
        }
      }
    } catch (e) {
      _logger.e('Error checking connectivity: $e');
      if (_currentStatus != ConnectivityStatus.unknown) {
        _currentStatus = ConnectivityStatus.unknown;
        _statusController.add(_currentStatus);
      }
    }
  }
  
  /// Force connectivity check
  Future<void> forceCheck() async {
    await _checkConnectivity();
  }
}

/// Extension for easy connectivity checks
extension ConnectivityStatusExtension on ConnectivityStatus {
  bool get isConnected => this == ConnectivityStatus.connected;
  bool get isDisconnected => this == ConnectivityStatus.disconnected;
  bool get isUnknown => this == ConnectivityStatus.unknown;
  
  String get displayName {
    switch (this) {
      case ConnectivityStatus.connected:
        return 'Bağlı';
      case ConnectivityStatus.disconnected:
        return 'Bağlantı Yok';
      case ConnectivityStatus.unknown:
        return 'Bilinmiyor';
    }
  }
}