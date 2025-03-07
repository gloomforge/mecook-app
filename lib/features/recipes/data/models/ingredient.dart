class Ingredient {
  final int id;
  final String name;
  final String searchValue;

  Ingredient({required this.id, required this.name, required this.searchValue});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      searchValue: json['searchValue'],
    );
  }
}
