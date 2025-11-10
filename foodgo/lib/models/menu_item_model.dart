import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final List<String> sizes;
  final List<String> toppings;
  final bool isAvailable;
  
  // ✨ Thêm các thuộc tính mới
  final List<ToppingOption> toppingOptions;
  final List<String> ingredients;
  final String restaurantId;
  final bool isNew;
  final int soldCount;
  final DateTime createdAt;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.sizes = const [],
    this.toppings = const [],
    this.isAvailable = true,
    this.toppingOptions = const [],
    this.ingredients = const [],
    this.restaurantId = '',
    this.isNew = false,
    this.soldCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _parseDouble(json['price']),
      imageUrl: json['imageUrl']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      
      // ✅ Safe parsing cho arrays
      sizes: _parseStringList(json['sizes']),
      toppings: _parseStringList(json['toppings']),
      ingredients: _parseStringList(json['ingredients']),
      
      isAvailable: json['isAvailable'] is bool ? json['isAvailable'] : true,
      isNew: json['isNew'] is bool ? json['isNew'] : false,
      soldCount: _parseInt(json['soldCount']),
      restaurantId: json['restaurantId']?.toString() ?? '',
      
      // ✅ Safe parsing cho toppingOptions
      toppingOptions: _parseToppingOptions(json['toppingOptions']),
      
      // ✅ Safe parsing cho DateTime
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  // ✅ Helper methods để parse safe
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static List<ToppingOption> _parseToppingOptions(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) {
        if (e is Map<String, dynamic>) {
          return ToppingOption.fromJson(e);
        } else if (e is String) {
          // Fallback: nếu là string thì tạo ToppingOption với price = 0
          return ToppingOption(name: e, price: 0);
        }
        return ToppingOption(name: e.toString(), price: 0);
      }).toList();
    }
    return [];
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    return DateTime.now();
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
      'toppingOptions': toppingOptions.map((e) => e.toJson()).toList(),
      'ingredients': ingredients,
      'restaurantId': restaurantId,
      'isNew': isNew,
      'soldCount': soldCount,
      'createdAt': createdAt.toIso8601String(),
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
    List<ToppingOption>? toppingOptions,
    List<String>? ingredients,
    String? restaurantId,
    bool? isNew,
    int? soldCount,
    DateTime? createdAt,
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
      toppingOptions: toppingOptions ?? this.toppingOptions,
      ingredients: ingredients ?? this.ingredients,
      restaurantId: restaurantId ?? this.restaurantId,
      isNew: isNew ?? this.isNew,
      soldCount: soldCount ?? this.soldCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ✨ Business logic methods
  bool get isBestseller => soldCount >= 500;
  bool get isRecentlyAdded {
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;
    return (difference <= 30) || isNew;
  }

  String get formattedPrice {
    return '${price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    )}đ';
  }

  CategoryInfo get categoryInfo {
    switch (category) {
      case 'burger':
        return CategoryInfo('Burger', '🍔');
      case 'chicken':
        return CategoryInfo('Gà Rán', '🍗');
      case 'pizza':
        return CategoryInfo('Pizza', '🍕');
      case 'grilled_chicken':
        return CategoryInfo('Gà Nướng', '🔥');
      case 'drink':
        return CategoryInfo('Đồ Uống', '🥤');
      case 'dessert':
        return CategoryInfo('Tráng Miệng', '🍰');
      case 'side':
        return CategoryInfo('Ăn Kèm', '🍟');
      case 'sandwich':
        return CategoryInfo('Sandwich', '🥪');
      case 'noodle':
        return CategoryInfo('Mì Pasta', '🍝');
      case 'combo':
        return CategoryInfo('Combo', '🎁');
      default:
        return CategoryInfo('Khác', '🍽️');
    }
  }

  String get ingredientsString => ingredients.join(', ');

  String get availabilityStatus {
    if (!isAvailable) return 'Tạm hết';
    if (isNew) return 'Món mới';
    if (isBestseller) return 'Bán chạy';
    return 'Có sẵn';
  }
}

class ToppingOption {
  final String name;
  final double price;

  ToppingOption({
    required this.name,
    required this.price,
  });

  factory ToppingOption.fromJson(Map<String, dynamic> json) {
    return ToppingOption(
      name: json['name']?.toString() ?? '',
      price: MenuItemModel._parseDouble(json['price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }

  String get formattedPrice {
    if (price == 0) return 'Miễn phí';
    return '+${price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    )}đ';
  }
}

class CategoryInfo {
  final String name;
  final String icon;

  CategoryInfo(this.name, this.icon);

  @override
  String toString() => '$icon $name';
}
