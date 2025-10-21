import 'menu_item_model.dart';
import 'voucher_model.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final int estimatedTime;
  final String address;
  final List<MenuItemModel> menu;
  final List<VoucherModel> promotions;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.estimatedTime,
    required this.address,
    this.menu = const [],
    this.promotions = const [],
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) => RestaurantModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    rating: (json['rating'] ?? 0).toDouble(),
    estimatedTime: json['estimatedTime'] ?? 0,
    address: json['address'] ?? '',
    menu: (json['menu'] as List<dynamic>?)
        ?.map((e) => MenuItemModel.fromJson(e))
        .toList() ??
        [],
    promotions: (json['promotions'] as List<dynamic>?)
        ?.map((e) => VoucherModel.fromJson(e))
        .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'rating': rating,
    'estimatedTime': estimatedTime,
    'address': address,
    'menu': menu.map((e) => e.toJson()).toList(),
    'promotions': promotions.map((e) => e.toJson()).toList(),
  };
}
