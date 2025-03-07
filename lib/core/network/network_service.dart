import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../../main.dart';

class NetworkService {
  static const int connectionTimeout = 5;
  static const int maxRetryAttempts = 3;
  
  static Future<bool> isConnected({String? baseUrl}) async {
    try {
      final url = Uri.parse("${baseUrl ?? AppConfig.serverUrl}/api/ping");
      final response = await http.get(url).timeout(Duration(seconds: connectionTimeout));
      return response.statusCode == 200;
    } catch (_) {
      return await hasInternetConnection();
    }
  }
  
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<T?> safeRequest<T>(
    Future<T> Function() request, {
    String? baseUrl,
    bool navigateOnFailure = true,
  }) async {
    int attempt = 0;
    int delaySeconds = 1;
    
    while (attempt < maxRetryAttempts) {
      if (await isConnected(baseUrl: baseUrl)) {
        try {
          return await request();
        } catch (e) {
          print("Ошибка запроса (попытка ${attempt + 1}): $e");
        }
      }
      
      await Future.delayed(Duration(seconds: delaySeconds));
      delaySeconds = delaySeconds * 2;
      attempt++;
    }
    
    if (navigateOnFailure && navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushReplacementNamed('/noConnection');
    }
    
    return null;
  }

  static Future<bool> resetConnection() async {
    try {
      final serverHost = AppConfig.serverUrl
          .replaceFirst("http://", "")
          .replaceFirst("https://", "")
          .split(":")[0];
          
      await InternetAddress.lookup(serverHost);
      
      return await hasInternetConnection();
    } catch (_) {
      return false;
    }
  }
  
  static Future<Map<String, dynamic>> getConnectionStatus() async {
    final hasInternet = await hasInternetConnection();
    final serverConnected = hasInternet ? await isConnected() : false;
    
    return {
      'hasInternet': hasInternet,
      'serverConnected': serverConnected,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
