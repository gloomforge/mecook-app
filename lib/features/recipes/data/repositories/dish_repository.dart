import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mecook_application/core/constants.dart';
import 'package:mecook_application/core/network/network_service.dart';
import '../models/ingredient.dart';
import '../models/dish.dart';

class DishRepository {
  final String baseUrl;
  DishRepository({this.baseUrl = AppConfig.serverUrl});

  Future<List<Ingredient>> fetchIngredients() async {
    final result = await NetworkService.safeRequest(() async {
      final response = await http.get(Uri.parse('$baseUrl/api/ingredients'));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> data = jsonDecode(decodedBody);
        return data.map((json) => Ingredient.fromJson(json)).toList();
      }
      throw Exception("Failed to load ingredients");
    }, baseUrl: baseUrl);

    return result ?? [];
  }

  Future<List<Dish>> fetchDishes() async {
    final result = await NetworkService.safeRequest(() async {
      final response = await http.get(Uri.parse('$baseUrl/api/dishes'));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> data = jsonDecode(decodedBody);
        return data.map((json) => Dish.fromJson(json)).toList();
      }
      throw Exception("Failed to load dishes");
    }, baseUrl: baseUrl);

    return result ?? [];
  }
}
