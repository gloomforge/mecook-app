import 'package:flutter/foundation.dart';
import 'package:mecook_application/features/recipes/data/models/dish_card_block.dart';
import 'package:mecook_application/features/recipes/data/repositories/dish_card_repository.dart';

class DishCardViewModel extends ChangeNotifier {
  final DishCardRepository repository;
  List<DishCardBlock> dishCardBlocks = [];
  bool loading = false;

  DishCardViewModel({required this.repository});

  Future<void> loadDishCardBlocks(int dishId) async {
    loading = true;
    notifyListeners();
    try {
      dishCardBlocks = await repository.fetchDishCardBlocksByDishId(dishId);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
