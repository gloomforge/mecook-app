import 'dart:async';
import 'package:flutter/material.dart';
import 'network_service.dart';
import 'network_status_provider.dart';

class ConnectivityNotifier extends ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;
  
  late NetworkStatusProvider _networkStatusProvider;
  Function? _networkStatusListener;
  
  ConnectivityNotifier() {
    _networkStatusProvider = NetworkStatusProvider();
    _isConnected = _networkStatusProvider.isConnected;
  }

  Future<void> checkConnection() async {
    await _networkStatusProvider.checkConnection();
    _isConnected = _networkStatusProvider.isConnected;
    notifyListeners();
  }

  void startMonitoring() {
    _networkStatusProvider.initialize();
    
    if (_networkStatusListener != null) {
      _networkStatusProvider.removeListener(_networkStatusListener as void Function());
    }
    
    _networkStatusListener = () {
      final newConnectionStatus = _networkStatusProvider.isConnected;
      if (newConnectionStatus != _isConnected) {
        _isConnected = newConnectionStatus;
        notifyListeners();
      }
    };
    
    _networkStatusProvider.addListener(_networkStatusListener as void Function());
    
    checkConnection();
  }
  
  Future<bool> retryConnection() async {
    final result = await _networkStatusProvider.retryConnection();
    if (_isConnected != result) {
      _isConnected = result;
      notifyListeners();
    }
    return result;
  }

  @override
  void dispose() {
    if (_networkStatusListener != null) {
      _networkStatusProvider.removeListener(_networkStatusListener as void Function());
    }
    _networkStatusProvider.dispose();
    super.dispose();
  }
}
