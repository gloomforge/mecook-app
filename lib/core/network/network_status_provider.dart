import 'dart:async';
import 'package:flutter/foundation.dart';
import 'network_service.dart';

enum ConnectionStatus {
  unknown,
  disconnected,
  connected,
  serverUnavailable
}

class NetworkStatusProvider with ChangeNotifier {
  ConnectionStatus _status = ConnectionStatus.unknown;
  Timer? _periodicCheck;
  bool _initialized = false;
  
  static const int checkInterval = 10000;
  
  ConnectionStatus get status => _status;
  bool get isConnected => _status == ConnectionStatus.connected;
  bool get isDisconnected => _status == ConnectionStatus.disconnected;
  bool get isServerUnavailable => _status == ConnectionStatus.serverUnavailable;
  
  NetworkStatusProvider() {
    initialize();
  }
  
  Future<void> initialize() async {
    if (_initialized) return;
    
    _initialized = true;
    await checkConnection();
    
    _periodicCheck = Timer.periodic(
      Duration(milliseconds: checkInterval), 
      (_) => checkConnection()
    );
  }
  
  Future<ConnectionStatus> checkConnection() async {
    try {
      final connectionStatus = await NetworkService.getConnectionStatus();
      
      if (!connectionStatus['hasInternet']) {
        _updateStatus(ConnectionStatus.disconnected);
      } else if (!connectionStatus['serverConnected']) {
        _updateStatus(ConnectionStatus.serverUnavailable);
      } else {
        _updateStatus(ConnectionStatus.connected);
      }
    } catch (_) {
      _updateStatus(ConnectionStatus.disconnected);
    }
    
    return _status;
  }
  
  void _updateStatus(ConnectionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }
  
  Future<bool> retryConnection() async {
    final hasConnectivity = await NetworkService.resetConnection();
    if (hasConnectivity) {
      await checkConnection();
    }
    return isConnected;
  }
  
  @override
  void dispose() {
    _periodicCheck?.cancel();
    super.dispose();
  }
} 