class Country {
  final int id;
  final String name;
  final String? imageUrl;

  Country({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }
} 