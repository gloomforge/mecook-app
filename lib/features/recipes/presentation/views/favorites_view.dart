import 'package:flutter/material.dart';
import 'package:mecook_application/features/recipes/presentation/widgets/dish_card.dart';
import 'package:mecook_application/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:mecook_application/core/constants.dart';

class FavoritesView extends StatefulWidget {
  final AuthViewModel authViewModel;

  const FavoritesView({
    Key? key,
    required this.authViewModel,
  }) : super(key: key);

  @override
  _FavoritesViewState createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _loadFavorites();
      });
    } else {
      Future.delayed(Duration.zero, () {
        _loadFavorites();
      });
    }
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await widget.authViewModel.loadFavoriteDishes();
    } catch (e) {
      print('Ошибка при загрузке избранных блюд: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Поиск в избранном",
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 18),
        filled: true,
        fillColor: Colors.white,
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }

  Widget _buildFavoritesInfo() {
    return Row(
      children: [
        Icon(
          Icons.favorite,
          size: 18,
          color: AppColors.primaryColor,
        ),
        SizedBox(width: 8),
        Text(
          "Избранные блюда",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: 8),
        if (widget.authViewModel.favoriteDishes.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.authViewModel.favoriteDishes.length.toString(),
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFavoritesInfo(),
              SizedBox(height: 12),
              _buildSearchBar(),
            ],
          ),
        ),
        
        Expanded(
          child: _buildBody(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    final favorites = widget.authViewModel.favoriteDishes;
    final filteredFavorites = _searchQuery.isEmpty
        ? favorites
        : favorites.where((dish) {
            final dishName = dish.name.toLowerCase();
            return dishName.contains(_searchQuery.toLowerCase());
          }).toList();

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryColor,
      backgroundColor: Colors.white,
      onRefresh: _loadFavorites,
      child: filteredFavorites.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 180,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border, 
                          size: 40, 
                          color: Colors.grey.shade300
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? "Нет избранных блюд"
                              : "Блюда не найдены",
                          style: TextStyle(
                            fontSize: 15, 
                            fontWeight: FontWeight.w500,
                            color: Colors.black87
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? "Добавьте блюда в избранное"
                              : "Попробуйте изменить поиск",
                          style: TextStyle(
                            fontSize: 13, 
                            color: Colors.grey.shade600
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredFavorites.length,
              itemBuilder: (context, index) {
                final dish = filteredFavorites[index];
                return DishCard(
                  dish: dish,
                  isFavorite: true,
                  onFavoriteToggle: () {},
                  inFavoritesSection: true,
                );
              },
            ),
    );
  }
}
