import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mecook_application/features/recipes/data/models/dish.dart';
import 'package:mecook_application/features/recipes/presentation/views/dish_detail_view.dart';
import 'package:mecook_application/features/recipes/data/repositories/dish_card_repository.dart';
import 'package:mecook_application/features/recipes/presentation/view_models/dish_card_view_model.dart';
import 'package:mecook_application/core/constants.dart';
import 'package:mecook_application/features/auth/presentation/view_models/auth_view_model.dart';

class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final bool inFavoritesSection;
  final VoidCallback onPressed;

  const FavoriteButton({
    Key? key,
    required this.isFavorite,
    required this.inFavoritesSection,
    required this.onPressed,
  }) : super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInBack,
      ),
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }
  
  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite && !_controller.isAnimating) {
      _controller.forward(from: 0.0);
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          widget.onPressed();
          if (!_controller.isAnimating) {
            _controller.forward(from: 0.0);
          }
        },
        splashColor: AppColors.primaryColor.withOpacity(0.1),
        highlightColor: AppColors.primaryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  widget.inFavoritesSection
                    ? Icons.delete_outline
                    : (widget.isFavorite ? Icons.favorite : Icons.favorite_border),
                  color: widget.inFavoritesSection
                    ? Colors.grey
                    : (widget.isFavorite ? AppColors.primaryColor : Colors.grey.shade400),
                  size: 20,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DishCard extends StatelessWidget {
  final Dish dish;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final bool inFavoritesSection;
  
  const DishCard({
    Key? key,
    required this.dish,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.inFavoritesSection = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: true);
    final isFavoriteFromViewModel = authViewModel.isDishFavorite(dish.id);
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ChangeNotifierProvider(
                  create: (_) => DishCardViewModel(repository: DishCardRepository()),
                  child: DishDetailView(dish: dish),
                );
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (dish.country.isNotEmpty) 
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: AppColors.primaryColor.withOpacity(0.7),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  dish.country,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  FavoriteButton(
                    isFavorite: isFavoriteFromViewModel,
                    inFavoritesSection: inFavoritesSection,
                    onPressed: () {
                      authViewModel.toggleFavorite(dish);
                    },
                  ),
                ],
              ),
              
              if (dish.description.isNotEmpty) ...[
                SizedBox(height: 10),
                Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
                SizedBox(height: 10),
              ],
              
              if (dish.description.isNotEmpty) ...[
                Text(
                  dish.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 14,
                    color: AppColors.primaryColor.withOpacity(0.7),
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Ингредиенты:",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: dish.ingredients.take(3).map((ingredient) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.primaryColor.withOpacity(0.1), width: 0.5),
                    ),
                    child: Text(
                      ingredient,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              if (dish.ingredients.length > 3) ...[
                SizedBox(height: 5),
                Text(
                  "... и ещё ${dish.ingredients.length - 3}",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
