import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {
  final String baseUrl = "http://localhost:8080";
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final url = Uri.parse("$baseUrl/api/auth/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"identifier": identifier, "password": password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    try {
      var error = jsonDecode(response.body);
      return {"error": error["message"] ?? "Неверный логин или пароль"};
    } catch (_) {
      return {"error": "Неверный логин или пароль"};
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final url = Uri.parse("$baseUrl/api/auth/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
      }),
    );
    if (response.statusCode == 200) {
      return {"success": true};
    }
    try {
      var error = jsonDecode(response.body);
      return {"error": error["message"] ?? "Ошибка регистрации"};
    } catch (_) {
      return {"error": "Ошибка регистрации"};
    }
  }
}
