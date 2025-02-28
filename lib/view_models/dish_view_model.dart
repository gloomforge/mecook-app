import '../models/ingredient.dart';
import '../models/dish.dart';
import '../repositories/dish_repository.dart';

class DishViewModel {
  final DishRepository repository = DishRepository();
  List<Ingredient> allIngredients = [];
  List<Dish> allDishes = [];
  List<Ingredient> selectedIngredients = [];
  List<Dish> filteredDishes = [];
  bool loadingIngredients = false;
  bool loadingDishes = false;
  Future<void> loadIngredients() async {
    loadingIngredients = true;
    allIngredients = await repository.fetchIngredients();
    loadingIngredients = false;
  }

  Future<void> loadDishes() async {
    loadingDishes = true;
    allDishes = await repository.fetchDishes();
    loadingDishes = false;
  }

  Future<void> updateFilteredDishes() async {
    if (selectedIngredients.isEmpty) {
      filteredDishes = [];
      return;
    }
    if (allDishes.isEmpty) {
      await loadDishes();
    }
    filteredDishes =
        allDishes.where((dish) {
          return selectedIngredients.every(
            (selected) => dish.ingredients.any(
              (d) => d.toLowerCase() == selected.name.toLowerCase(),
            ),
          );
        }).toList();
  }

  void addIngredient(Ingredient ingredient) {
    if (!selectedIngredients.any((ing) => ing.id == ingredient.id)) {
      selectedIngredients.add(ingredient);
    }
  }

  void removeIngredient(Ingredient ingredient) {
    selectedIngredients.removeWhere((ing) => ing.id == ingredient.id);
  }
}
