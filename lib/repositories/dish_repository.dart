import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ingredient.dart';
import '../models/dish.dart';

class DishRepository {
  final String baseUrl = "http://localhost:8080";
  Future<List<Ingredient>> fetchIngredients() async {
    final response = await http.get(Uri.parse('$baseUrl/api/ingredients'));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = jsonDecode(decodedBody);
      return data.map((json) => Ingredient.fromJson(json)).toList();
    }
    throw Exception("Failed to load ingredients");
  }

  Future<List<Dish>> fetchDishes() async {
    final response = await http.get(Uri.parse('$baseUrl/api/dishes'));
    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = jsonDecode(decodedBody);
      return data.map((json) => Dish.fromJson(json)).toList();
    }
    throw Exception("Failed to load dishes");
  }
}
