import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mecook_application/features/recipes/data/models/dish.dart';
import 'package:mecook_application/features/recipes/data/models/dish_card_block.dart';
import 'package:mecook_application/features/recipes/presentation/view_models/dish_card_view_model.dart';

class DishDetailView extends StatefulWidget {
  final Dish dish;
  const DishDetailView({Key? key, required this.dish}) : super(key: key);

  @override
  _DishDetailViewState createState() => _DishDetailViewState();
}

class _DishDetailViewState extends State<DishDetailView> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DishCardViewModel>(context);
    if (!_initialized) {
      _initialized = true;
      viewModel.loadDishCardBlocks(widget.dish.id);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dish.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<DishCardViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (viewModel.dishCardBlocks.isEmpty) {
                  return const Text('Нет данных');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      viewModel.dishCardBlocks
                          .map((block) => _buildBlock(block))
                          .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(DishCardBlock block) {
    switch (block.type) {
      case 'IMAGE':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Image.network(
            block.value,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      case 'HEADER':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            block.value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
      case 'TEXT':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(block.value, style: const TextStyle(fontSize: 16)),
        );
      default:
        return Container();
    }
  }
}
