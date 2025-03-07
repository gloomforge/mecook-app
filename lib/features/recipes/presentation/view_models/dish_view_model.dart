import 'package:mecook_application/features/recipes/data/models/ingredient.dart';
import 'package:mecook_application/features/recipes/data/models/dish.dart';
import 'package:mecook_application/features/recipes/data/models/country.dart';
import 'package:mecook_application/features/recipes/data/repositories/dish_repository.dart';
import 'package:mecook_application/features/recipes/data/repositories/country_repository.dart';
import 'package:flutter/foundation.dart';

class DishViewModel extends ChangeNotifier {
  final DishRepository dishRepository = DishRepository();
  final CountryRepository countryRepository = CountryRepository();
  
  List<Ingredient> allIngredients = [];
  List<Dish> allDishes = [];
  List<Country> allCountries = [];
  
  List<Ingredient> selectedIngredients = [];
  Country? selectedCountry;
  
  List<Dish> filteredDishes = [];
  List<Dish> recommendedDishes = [];
  
  bool loadingIngredients = false;
  bool loadingDishes = false;
  bool loadingCountries = false;

  Future<void> loadIngredients() async {
    loadingIngredients = true;
    allIngredients = await dishRepository.fetchIngredients();
    loadingIngredients = false;
    notifyListeners();
  }

  Future<void> loadDishes() async {
    loadingDishes = true;
    allDishes = await dishRepository.fetchDishes();
    loadingDishes = false;

    if (selectedIngredients.isEmpty && selectedCountry == null) {
      recommendedDishes = List.from(allDishes);
      if (recommendedDishes.length > 10) {
        recommendedDishes = recommendedDishes.sublist(0, 10);
      }
    }
    
    notifyListeners();
  }
  
  Future<void> loadCountries() async {
    loadingCountries = true;
    allCountries = await countryRepository.fetchCountries();
    loadingCountries = false;
    notifyListeners();
  }

  Future<void> updateFilteredDishes() async {
    if (selectedIngredients.isEmpty && selectedCountry == null) {
      filteredDishes = [];
      return;
    }
    
    if (allDishes.isEmpty) {
      await loadDishes();
    }
    
    filteredDishes = allDishes.where((dish) {
      bool matchesIngredients = true;
      bool matchesCountry = true;
      
      if (selectedIngredients.isNotEmpty) {
        matchesIngredients = selectedIngredients.every(
          (selected) => dish.ingredients.any(
            (ingredient) => ingredient.toLowerCase() == selected.name.toLowerCase(),
          ),
        );
      }
      
      if (selectedCountry != null) {
        matchesCountry = dish.country.toLowerCase() == selectedCountry!.name.toLowerCase();
      }
      
      return matchesIngredients && matchesCountry;
    }).toList();
    
    notifyListeners();
  }

  void addIngredient(Ingredient ingredient) {
    if (!selectedIngredients.any((ing) => ing.id == ingredient.id)) {
      selectedIngredients.add(ingredient);
      updateFilteredDishes();
    }
  }

  void removeIngredient(Ingredient ingredient) {
    selectedIngredients.removeWhere((ing) => ing.id == ingredient.id);
    updateFilteredDishes();
  }
  
  void selectCountry(Country country) {
    if (selectedCountry?.id == country.id) {
      selectedCountry = null;
    } else {
      selectedCountry = country;
    }
    updateFilteredDishes();
  }
  
  void clearFilters() {
    selectedIngredients.clear();
    selectedCountry = null;
    filteredDishes.clear();
    notifyListeners();
  }
  
  @override
  void dispose() {
    allIngredients.clear();
    allDishes.clear();
    allCountries.clear();
    selectedIngredients.clear();
    filteredDishes.clear();
    recommendedDishes.clear();
    selectedCountry = null;
    super.dispose();
  }
}
