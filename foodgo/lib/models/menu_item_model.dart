class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<Map<String, dynamic>> toppings;
  final List<String> ingredients;
  final bool isAvailable;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.toppings = const [],
    this.ingredients = const [],
    this.isAvailable = true,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    imageUrl: json['imageUrl'] ?? '',
    toppings:
    List<Map<String, dynamic>>.from(json['toppings'] ?? const []),
    ingredients:
    (json['ingredients'] as List?)?.map((e) => e.toString()).toList() ??
        [],
    isAvailable: json['isAvailable'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
    'toppings': toppings,
    'ingredients': ingredients,
    'isAvailable': isAvailable,
  };
}
