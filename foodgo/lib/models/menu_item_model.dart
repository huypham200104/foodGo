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
  final List<ToppingOption> toppingOptions;
  final List<String> ingredients;
  final String restaurantId;
  final bool isNew;
  final int soldCount;
  final DateTime createdAt;
  // Getter for categoryInfo
  CategoryInfo get categoryInfo => CategoryInfo(category, '🍽️');

  // Getter for formattedPrice
  String get formattedPrice {
    if (price == 0) return '';
    final s = price.toInt().toString();
    if (s.length <= 3) return '$s VND';
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return '${buffer.toString()} VND';
  }

  // Bestseller: soldCount > 50 (tuỳ chỉnh theo logic của bạn)
  bool get isBestseller => soldCount > 50;

  // Recently added: tạo trong 7 ngày gần nhất
  bool get isRecentlyAdded => DateTime.now().difference(createdAt).inDays < 7;

  // Effective topping options: nếu `toppingOptions` rỗng nhưng `toppings` (List<String>) có dữ liệu,
  // chuyển chúng thành `ToppingOption` với giá 0 để dễ hiển thị trên UI.
  List<ToppingOption> get effectiveToppingOptions {
    if (toppingOptions.isNotEmpty) return toppingOptions;
    if (toppings.isNotEmpty) {
      return toppings.map((t) => ToppingOption(name: t, price: 0)).toList();
    }
    return <ToppingOption>[];
  }

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
      sizes: _parseStringList(json['sizes']),
      toppings: _parseStringList(json['toppings']),
      ingredients: _parseStringList(json['ingredients']),
      isAvailable: json['isAvailable'] is bool ? json['isAvailable'] : true,
      isNew: json['isNew'] is bool ? json['isNew'] : false,
      soldCount: _parseInt(json['soldCount']),
      restaurantId: json['restaurantId']?.toString() ?? '',
      // Some data sources put topping objects under 'toppings' (array of maps),
      // while others use 'toppingOptions'. Prefer explicit 'toppingOptions',
      // otherwise try parsing 'toppings' as topping option objects.
      toppingOptions: _parseToppingOptions(json['toppingOptions'] ?? json['toppings']), // 👈 Đảm bảo parse đúng
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  // ✅ Helper methods để parse dữ liệu an toàn
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
          return ToppingOption.fromJson(e); // 👈 Parse từng phần tử thành ToppingOption
        } else if (e is String) {
          return ToppingOption(name: e, price: 0); // Fallback nếu chỉ có tên
        }
        return ToppingOption(name: e.toString(), price: 0); // Fallback nếu không xác định được
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
    final s = price.toInt().toString();
    if (s.length <= 3) return '$s VND';
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return '${buffer.toString()} VND';
  }
}

class CategoryInfo {
  final String name;
  final String icon;

  CategoryInfo(this.name, this.icon);

  @override
  String toString() => '$icon $name';
}

