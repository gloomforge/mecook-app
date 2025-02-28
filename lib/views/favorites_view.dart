import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/favorites_notifier.dart';
import '../widgets/dish_card.dart';
import '../view_models/auth_view_model.dart';

class FavoritesView extends StatefulWidget {
  final String token;
  final AuthViewModel authViewModel;
  const FavoritesView({
    Key? key,
    required this.token,
    required this.authViewModel,
  }) : super(key: key);
  @override
  _FavoritesViewState createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  void initState() {
    super.initState();
    Provider.of<FavoritesNotifier>(
      context,
      listen: false,
    ).loadFavorites(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesNotifier>(
      builder: (context, notifier, child) {
        return RefreshIndicator(
          onRefresh: () => notifier.loadFavorites(widget.token),
          child:
              notifier.favorites.isEmpty
                  ? ListView(
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("Нет избранных блюд"),
                        ),
                      ),
                    ],
                  )
                  : ListView.builder(
                    itemCount: notifier.favorites.length,
                    itemBuilder: (context, index) {
                      final dish = notifier.favorites[index];
                      return DishCard(
                        dish: dish,
                        token: widget.token,
                        inFavoritesSection: true,
                      );
                    },
                  ),
        );
      },
    );
  }
}
