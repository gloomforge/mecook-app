import 'package:flutter/material.dart';
import '../view_models/dish_view_model.dart';
import '../models/ingredient.dart';
import '../widgets/dish_card.dart';
import 'favorites_view.dart';
import '../view_models/auth_view_model.dart';

class HomeView extends StatefulWidget {
  final AuthViewModel authViewModel;
  const HomeView({Key? key, required this.authViewModel}) : super(key: key);
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final DishViewModel dishViewModel = DishViewModel();
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    dishViewModel.loadIngredients().then((_) => setState(() {}));
    widget.authViewModel.loadFavoriteDishes().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    Widget searchView =
        dishViewModel.loadingIngredients
            ? Center(child: CircularProgressIndicator())
            : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Autocomplete<Ingredient>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty)
                        return const Iterable<Ingredient>.empty();
                      return dishViewModel.allIngredients.where(
                        (Ingredient ingredient) => ingredient.name
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()),
                      );
                    },
                    displayStringForOption: (Ingredient option) => option.name,
                    fieldViewBuilder: (
                      BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
                      return TextField(
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Введите ингредиент',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (String value) => onFieldSubmitted(),
                      );
                    },
                    onSelected: (Ingredient selection) async {
                      dishViewModel.addIngredient(selection);
                      await dishViewModel.updateFilteredDishes();
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 16),
                  if (dishViewModel.selectedIngredients.isNotEmpty)
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: dishViewModel.selectedIngredients.length,
                        itemBuilder: (context, index) {
                          final ingredient =
                              dishViewModel.selectedIngredients[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Chip(
                              label: Text(ingredient.name),
                              onDeleted: () async {
                                dishViewModel.removeIngredient(ingredient);
                                await dishViewModel.updateFilteredDishes();
                                setState(() {});
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 16),
                  Expanded(
                    child:
                        dishViewModel.selectedIngredients.isEmpty
                            ? Center(
                              child: Text("Выберите ингредиент для поиска"),
                            )
                            : dishViewModel.loadingDishes
                            ? Center(child: CircularProgressIndicator())
                            : dishViewModel.filteredDishes.isEmpty
                            ? Center(
                              child: Text(
                                "Блюда не найдены для выбранных ингредиентов",
                              ),
                            )
                            : ListView.builder(
                              itemCount: dishViewModel.filteredDishes.length,
                              itemBuilder: (context, index) {
                                final dish =
                                    dishViewModel.filteredDishes[index];
                                return DishCard(
                                  dish: dish,
                                  token: widget.authViewModel.token!,
                                );
                              },
                            ),
                  ),
                ],
              ),
            );
    return Scaffold(
      appBar: AppBar(
        title: Text("Поиск блюд по ингредиентам"),
        automaticallyImplyLeading: false,
      ),
      body:
          _selectedIndex == 0
              ? searchView
              : FavoritesView(
                token: widget.authViewModel.token!,
                authViewModel: widget.authViewModel,
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Избранное'),
        ],
      ),
    );
  }
}
