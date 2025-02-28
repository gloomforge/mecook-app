import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dish.dart';
import 'dart:convert' show utf8;

class FavoritesRepository {
  final String baseUrl = "http://localhost:8080";

  Future<bool> addFavoriteDish(int dishId, String token) async {
    final url = Uri.parse("$baseUrl/api/users/favorites");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"dishId": dishId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavoriteDish(int dishId, String token) async {
    final url = Uri.parse("$baseUrl/api/users/favorites/$dishId");
    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Dish>?> fetchFavoriteDishes(String token) async {
    final url = Uri.parse("$baseUrl/api/users/favorites");
    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> data = jsonDecode(decodedBody);
        return data.map((json) => Dish.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
