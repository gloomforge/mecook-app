class Dish {
  final int id;
  final String name;
  final String description;
  final List<String> ingredients;
  final String country;
  final String? imageUrl;

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.country,
    this.imageUrl,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
      country: json['country'] ?? 'Неизвестно',
      imageUrl: json['imageUrl'],
    );
  }
}
