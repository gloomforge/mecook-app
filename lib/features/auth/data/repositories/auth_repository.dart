import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mecook_application/core/constants.dart';
import 'package:mecook_application/core/network/network_service.dart';

class AuthRepository {
  final String baseUrl;
  AuthRepository({this.baseUrl = AppConfig.serverUrl});

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final result = await NetworkService.safeRequest<Map<String, dynamic>>(
      () async {
        final response = await http.post(
          Uri.parse("$baseUrl/api/auth/login"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"identifier": identifier, "password": password}),
        );
        
        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
        
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map<String, dynamic>) {
            final errorCode = errorBody['status'] as int?;
            final errorMessage = errorBody['message'] as String?;
            
            if (errorMessage != null) {
              switch (errorCode) {
                case 401:
                  if (errorMessage.toLowerCase().contains("invalid credentials")) {
                    return {"error": "Неверный логин или пароль"};
                  }
                  break;
                case 404:
                  if (errorMessage.toLowerCase().contains("user not found")) {
                    return {"error": "Пользователь не найден. Убедитесь, что вы правильно ввели логин или email."};
                  }
                  break;
                case 403:
                  return {"error": "Доступ запрещен. Возможно, ваш аккаунт заблокирован."};
              }
              
              return {"error": errorMessage};
            }
          }
        } catch (e) {
        }
        
        switch (response.statusCode) {
          case 401:
            return {"error": "Неверный логин или пароль"};
          case 404:
            return {"error": "Пользователь не найден"};
          case 403:
            return {"error": "Доступ запрещен"};
          case 400:
            return {"error": "Некорректные данные запроса"};
          case 500:
          case 502:
          case 503:
            return {"error": "Ошибка сервера. Пожалуйста, попробуйте позже."};
          default:
            return {"error": "Произошла ошибка при входе: Код ${response.statusCode}"};
        }
      },
      baseUrl: baseUrl,
    );
    
    if (result == null) {
      return {"error": "Нет подключения к интернету. Проверьте соединение и попробуйте снова."};
    }
    return result;
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final result = await NetworkService.safeRequest<Map<String, dynamic>>(
      () async {
        final response = await http.post(
          Uri.parse("$baseUrl/api/auth/register"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "username": username,
            "email": email,
            "password": password,
            "confirmPassword": confirmPassword,
          }),
        );
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          try {
            final responseData = jsonDecode(response.body) as Map<String, dynamic>;
            
            responseData["success"] = true;
            
            if (!responseData.containsKey("message")) {
              responseData["message"] = "Регистрация выполнена успешно";
            }
            
            return responseData;
          } catch (e) {
            return {"success": true, "message": "Регистрация выполнена успешно"};
          }
        }
        
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map<String, dynamic>) {
            final errorCode = errorBody['status'] as int?;
            final errorMessage = errorBody['message'] as String?;
            
            if (errorMessage != null) {
              if (errorMessage.toLowerCase().contains("username already exists")) {
                return {"error": "Пользователь с таким именем уже существует"};
              } else if (errorMessage.toLowerCase().contains("email already exists")) {
                return {"error": "Email уже зарегистрирован"};
              } else if (errorMessage.toLowerCase().contains("passwords do not match")) {
                return {"error": "Пароли не совпадают"};
              }
              
              return {"error": errorMessage};
            }
          }
        } catch (e) {
        }
        
        final responseText = response.body.toLowerCase();
        
        switch (response.statusCode) {
          case 400:
            if (responseText.contains("username")) {
              return {"error": "Имя пользователя не соответствует требованиям"};
            } else if (responseText.contains("email")) {
              return {"error": "Неверный формат email"};
            } else if (responseText.contains("password")) {
              return {"error": "Пароль должен содержать минимум 6 символов"};
            }
            return {"error": "Некорректные данные для регистрации"};
          case 409:
            if (responseText.contains("username")) {
              return {"error": "Пользователь с таким именем уже существует"};
            } else if (responseText.contains("email")) {
              return {"error": "Email уже зарегистрирован"};
            }
            return {"error": "Пользователь с такими данными уже существует"};
          case 500:
          case 502:
          case 503:
            return {"error": "Ошибка сервера. Пожалуйста, попробуйте позже."};
          default:
            return {"error": "Ошибка при регистрации: Код ${response.statusCode}"};
        }
      },
      baseUrl: baseUrl,
    );
    
    if (result == null) {
      return {"error": "Нет подключения к интернету. Проверьте соединение и попробуйте снова."};
    }
    
    if (!result.containsKey("error") && !result.containsKey("success")) {
      result["success"] = true;
    }
    
    return result;
  }
  
  String _getReadableErrorMessage(String errorCode, String message) {
    if (message.contains("Invalid credentials")) {
      return "Неверный логин или пароль";
    }
    if (message.contains("User not found")) {
      return "Пользователь не найден";
    }
    
    if (message.contains("Username already exists")) {
      return "Пользователь с таким именем уже существует";
    }
    if (message.contains("Email already exists")) {
      return "Email уже зарегистрирован";
    }
    if (message.contains("Passwords do not match")) {
      return "Введенные пароли не совпадают";
    }
    
    return message;
  }
}
