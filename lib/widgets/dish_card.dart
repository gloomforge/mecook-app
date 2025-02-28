import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dish.dart';
import '../notifiers/favorites_notifier.dart';

class DishCard extends StatelessWidget {
  final Dish dish;
  final String token;
  final bool inFavoritesSection;
  const DishCard({
    Key? key,
    required this.dish,
    required this.token,
    this.inFavoritesSection = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final favoritesNotifier = Provider.of<FavoritesNotifier>(context);
    bool isFav = favoritesNotifier.isFavorite(dish);
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dish.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    inFavoritesSection
                        ? Icons.delete
                        : (isFav ? Icons.star : Icons.star_border),
                    color:
                        inFavoritesSection
                            ? Colors.red
                            : (isFav ? Colors.amber : null),
                  ),
                  onPressed: () async {
                    if (inFavoritesSection) {
                      await favoritesNotifier.removeFavorite(dish, token);
                    } else {
                      if (isFav) {
                        await favoritesNotifier.removeFavorite(dish, token);
                      } else {
                        await favoritesNotifier.addFavorite(dish, token);
                      }
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(dish.description, style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    dish.ingredients.map((ingredient) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 6, color: Colors.black54),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                ingredient,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
