import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mecook_application/core/constants.dart';
import 'package:mecook_application/core/network/network_service.dart';
import '../models/dish.dart';

class FavoritesRepository {
  final String baseUrl;
  FavoritesRepository({this.baseUrl = AppConfig.serverUrl});

  Future<bool> addFavoriteDish(String token, int dishId) async {
    final result = await NetworkService.safeRequest(() async {
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/favorites"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"dishId": dishId}),
      );
      return response.statusCode == 200;
    }, baseUrl: baseUrl);
    return result ?? false;
  }

  Future<bool> removeFavoriteDish(String token, int dishId) async {
    final result = await NetworkService.safeRequest(() async {
      final response = await http.delete(
        Uri.parse("$baseUrl/api/users/favorites/$dishId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      return response.statusCode == 200;
    }, baseUrl: baseUrl);
    return result ?? false;
  }

  Future<List<Dish>> fetchFavoriteDishes(String token) async {
    final result = await NetworkService.safeRequest(() async {
      final response = await http.get(
        Uri.parse("$baseUrl/api/users/favorites"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> data = jsonDecode(decodedBody);
        return data.map((json) => Dish.fromJson(json)).toList();
      }
      throw Exception("Failed to load favorite dishes");
    }, baseUrl: baseUrl);
    return result ?? [];
  }
}
