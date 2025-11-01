class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final List<String> sizes; // Đảm bảo có field này
  final List<String> toppings; // Đảm bảo có field này
  final bool isAvailable;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.sizes = const [], // Default empty list
    this.toppings = const [], // Default empty list
    this.isAvailable = true,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : const [],
      toppings: json['toppings'] != null ? List<String>.from(json['toppings']) : const [],
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'sizes': sizes,
      'toppings': toppings,
      'isAvailable': isAvailable,
    };
  }

  MenuItemModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    List<String>? sizes,
    List<String>? toppings,
    bool? isAvailable,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      sizes: sizes ?? this.sizes,
      toppings: toppings ?? this.toppings,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
