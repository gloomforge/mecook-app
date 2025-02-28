class Dish {
  final int id;
  final String name;
  final String description;
  final List<String> ingredients;
  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
  });
  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
    );
  }
}
