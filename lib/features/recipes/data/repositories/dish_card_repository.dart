import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mecook_application/core/constants.dart';
import 'package:mecook_application/core/network/network_service.dart';
import '../models/dish_card_block.dart';

class DishCardRepository {
  final String baseUrl;
  DishCardRepository({this.baseUrl = AppConfig.serverUrl});

  Future<List<DishCardBlock>> fetchDishCardBlocksByDishId(int dishId) async {
    final result = await NetworkService.safeRequest(() async {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dishes/card/id/$dishId'),
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> data = jsonDecode(decodedBody);
        return data.map((json) => DishCardBlock.fromJson(json)).toList();
      }
      throw Exception("Failed to load dish card blocks");
    }, baseUrl: baseUrl);
    return result ?? [];
  }
}
