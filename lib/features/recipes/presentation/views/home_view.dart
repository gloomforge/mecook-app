import 'package:flutter/material.dart';
import 'package:mecook_application/features/recipes/presentation/view_models/dish_view_model.dart';
import 'package:mecook_application/features/recipes/data/models/ingredient.dart';
import 'package:mecook_application/features/recipes/presentation/widgets/dish_card.dart';
import 'package:mecook_application/features/recipes/presentation/widgets/country_selector.dart';
import 'package:provider/provider.dart';
import 'favorites_view.dart';
import 'package:mecook_application/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:mecook_application/core/constants.dart';

class HomeView extends StatefulWidget {
  final AuthViewModel authViewModel;
  const HomeView({Key? key, required this.authViewModel}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late DishViewModel dishViewModel;
  int _selectedIndex = 0;
  bool _isDataInitialized = false;
  
  AnimationController? _animationController;
  Animation<double> _animation = AlwaysStoppedAnimation(0.0);
  
  final PageController _pageController = PageController();

  AnimationController get animationController {
    if (_animationController == null) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
      _animation = CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      );
    }
    return _animationController!;
  }

  @override
  void initState() {
    super.initState();
    
    dishViewModel = DishViewModel();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
    
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _loadInitialData();
      });
    } else {
      Future.delayed(Duration.zero, () {
        _loadInitialData();
      });
    }
  }
  
  Future<void> _loadInitialData() async {
    await _loadData();
    await widget.authViewModel.loadFavoriteDishes();
    setState(() {
      _isDataInitialized = true;
    });
  }
  
  Future<void> _loadData() async {
    await dishViewModel.loadIngredients();
    await dishViewModel.loadCountries();
    await dishViewModel.loadDishes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    dishViewModel.dispose();
    _pageController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        animationController.reverse();
      } else {
        animationController.forward();
      }
      
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showCountrySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCountrySelectorModal(),
    );
  }

  Widget _buildCountrySelectorModal() {
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = screenHeight * 0.7;
    
    return Container(
      height: modalHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.public,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  "Выберите страну",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: dishViewModel.loadingCountries 
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                  )
                : dishViewModel.allCountries.isEmpty
                    ? Center(
                        child: Text(
                          "Страны не найдены",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: dishViewModel.allCountries.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildCountryGridItem(
                              name: "Все страны",
                              imageUrl: null,
                              isSelected: dishViewModel.selectedCountry == null,
                              onTap: () {
                                setState(() {
                                  if (dishViewModel.selectedCountry != null) {
                                    dishViewModel.clearFilters();
                                  }
                                });
                                Navigator.pop(context);
                              },
                            );
                          } else {
                            final country = dishViewModel.allCountries[index - 1];
                            return _buildCountryGridItem(
                              name: country.name,
                              imageUrl: country.imageUrl,
                              isSelected: dishViewModel.selectedCountry?.id == country.id,
                              onTap: () {
                                setState(() {
                                  dishViewModel.selectCountry(country);
                                });
                                Navigator.pop(context);
                              },
                            );
                          }
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryGridItem({
    required String name, 
    String? imageUrl, 
    required bool isSelected, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 40,
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    spreadRadius: 0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.flag_outlined,
                            color: Colors.grey.shade400,
                            size: 24,
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.public,
                        color: isSelected ? AppColors.primaryColor : Colors.grey.shade400,
                        size: 24,
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryColor : AppColors.textPrimaryColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
      color: AppColors.primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                "MeCook",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Выход из аккаунта"),
                    content: Text("Вы действительно хотите выйти?"),
                    actions: [
                      TextButton(
                        child: Text("Отмена"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(
                          "Выйти",
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await widget.authViewModel.logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final filteredIngredients = dishViewModel.allIngredients
        .where((ingredient) => ingredient.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();
            
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _showCountrySelector,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: dishViewModel.selectedCountry != null && 
                           dishViewModel.selectedCountry!.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              dishViewModel.selectedCountry!.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.flag_outlined, 
                                    color: Colors.grey.shade400,
                                    size: 20,
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.public, 
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                          ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Страна",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        dishViewModel.selectedCountry?.name ?? "Все страны",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          Row(
            children: [
              Icon(
                Icons.restaurant,
                size: 20,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 8),
              Text(
                "Ингредиенты",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6),
              Text(
                "что есть в холодильнике?",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Поиск ингредиентов...",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 18),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          
          SizedBox(
            height: 38,
            child: filteredIngredients.isEmpty
                ? Center(
                    child: Text(
                      "Ингредиенты не найдены",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = filteredIngredients[index];
                      final isSelected = dishViewModel.selectedIngredients
                          .any((selected) => selected.id == ingredient.id);
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: FilterChip(
                          backgroundColor: Colors.grey.shade200,
                          selectedColor: AppColors.primaryColor,
                          checkmarkColor: Colors.white,
                          label: Text(
                            ingredient.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                dishViewModel.addIngredient(ingredient);
                              } else {
                                dishViewModel.removeIngredient(ingredient);
                              }
                            });
                          },
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      );
                    },
                  ),
          ),
          
          if (dishViewModel.selectedIngredients.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  "Выбранные ингредиенты",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    setState(() {
                      dishViewModel.clearSelectedIngredients();
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.clear_all,
                          size: 16,
                          color: AppColors.accentColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Очистить",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: dishViewModel.selectedIngredients.map((ingredient) {
                return Chip(
                  backgroundColor: AppColors.primaryColor,
                  label: Text(
                    ingredient.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  deleteIconColor: Colors.white,
                  onDeleted: () {
                    setState(() {
                      dishViewModel.removeIngredient(ingredient);
                    });
                  },
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilteredDishes() {
    if (!_isDataInitialized || dishViewModel.loadingDishes) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                strokeWidth: 2,
              ),
              SizedBox(height: 16),
              Text(
                "Загрузка блюд...",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        )
      );
    }

    final hasFilters = dishViewModel.selectedIngredients.isNotEmpty || 
                       dishViewModel.selectedCountry != null;
    
    final dishes = hasFilters 
        ? dishViewModel.filteredDishes 
        : dishViewModel.recommendedDishes;
    
    if (dishes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_outlined,
                size: 40,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                hasFilters
                    ? "Блюда не найдены"
                    : "Нет рекомендуемых блюд",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                hasFilters
                    ? "Попробуйте изменить фильтры"
                    : "Скоро здесь появятся рекомендации",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              if (hasFilters) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      dishViewModel.clearFilters();
                    });
                  },
                  child: Text("Сбросить фильтры"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        final dish = dishes[index];
        return DishCard(
          dish: dish,
          isFavorite: widget.authViewModel.isDishFavorite(dish.id),
          onFavoriteToggle: () {},
          inFavoritesSection: false,
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, "Главная"),
                _buildNavItem(1, Icons.favorite_border, Icons.favorite, "Избранное"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData inactiveIcon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primaryColor.withOpacity(0.2),
        highlightColor: AppColors.primaryColor.withOpacity(0.1),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
                offset: Offset(0, 2),
              )
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  key: ValueKey<bool>(isSelected),
                  color: isSelected ? Colors.white : Colors.grey.shade500,
                  size: 22,
                ),
              ),
              AnimatedSize(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: isSelected
                    ? Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: dishViewModel,
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedIndex = index;
                          if (index == 0) {
                            animationController.reverse();
                          } else {
                            animationController.forward();
                          }
                        });
                      },
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_animation.value * -50, 0),
                              child: Opacity(
                                opacity: 1 - _animation.value,
                                child: child,
                              ),
                            );
                          },
                          child: ListView(
                            padding: EdgeInsets.zero,
                            physics: BouncingScrollPhysics(),
                            children: [
                              _buildHeader(),
                              Padding(
                                padding: const EdgeInsets.only(left: 16, top: 16, bottom: 6),
                                child: Row(
                                  children: [
                                    Text(
                                      dishViewModel.selectedIngredients.isEmpty && dishViewModel.selectedCountry == null
                                          ? "Рекомендуемые блюда"
                                          : "Найденные блюда",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    if (dishViewModel.selectedIngredients.isNotEmpty || dishViewModel.selectedCountry != null)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          dishViewModel.filteredDishes.length.toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: _buildFilteredDishes(),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                        
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset((1 - _animation.value) * 50, 0),
                              child: Opacity(
                                opacity: _animation.value,
                                child: child,
                              ),
                            );
                          },
                          child: FavoritesView(authViewModel: widget.authViewModel),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomNavBar(),
          );
        }
      ),
    );
  }
}
