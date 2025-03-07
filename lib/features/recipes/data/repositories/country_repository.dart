import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mecook_application/core/constants.dart';
import 'package:mecook_application/core/network/network_service.dart';
import 'package:mecook_application/features/recipes/data/models/country.dart';

class CountryRepository {
  Future<List<Country>> fetchCountries() async {
    final result = await NetworkService.safeRequest(() async {
      final response = await http.get(
        Uri.parse('${AppConfig.serverUrl}/api/countries'),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => Country.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load countries');
      }
    });

    return result ?? [];
  }

  Future<Country> fetchCountryById(int id) async {
    final result = await NetworkService.safeRequest(() async {
      final response = await http.get(
        Uri.parse('${AppConfig.serverUrl}/api/countries/$id'),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return Country.fromJson(json.decode(decodedBody));
      } else {
        throw Exception('Failed to load country');
      }
    });

    return result!;
  }
} 