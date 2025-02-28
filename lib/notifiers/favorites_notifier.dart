import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../repositories/favorites_repository.dart';

class FavoritesNotifier extends ChangeNotifier {
  final FavoritesRepository _repository = FavoritesRepository();
  List<Dish> _favorites = [];
  List<Dish> get favorites => _favorites;
  Future<void> loadFavorites(String token) async {
    List<Dish>? dishes = await _repository.fetchFavoriteDishes(token);
    _favorites = dishes ?? [];
    notifyListeners();
  }

  Future<void> addFavorite(Dish dish, String token) async {
    bool success = await _repository.addFavoriteDish(dish.id, token);
    if (success) {
      await loadFavorites(token);
    }
  }

  Future<void> removeFavorite(Dish dish, String token) async {
    bool success = await _repository.removeFavoriteDish(dish.id, token);
    if (success) {
      await loadFavorites(token);
    }
  }

  bool isFavorite(Dish dish) {
    return _favorites.any((d) => d.id == dish.id);
  }
}
