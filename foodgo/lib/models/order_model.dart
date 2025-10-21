import 'cart_item_model.dart';
import 'user_model.dart';
import 'restaurant_model.dart';

class OrderModel {
  final String id;
  final String status;
  final UserModel user;
  final RestaurantModel restaurant;
  final List<CartItemModel> items;
  final double deliveryFee;
  final double totalPrice;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String note;

  OrderModel({
    required this.id,
    required this.status,
    required this.user,
    required this.restaurant,
    required this.items,
    required this.deliveryFee,
    required this.totalPrice,
    required this.paymentMethod,
    required this.createdAt,
    this.deliveredAt,
    this.note = '',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] ?? '',
    status: json['status'] ?? '',
    user: UserModel.fromJson(json['user']),
    restaurant: RestaurantModel.fromJson(json['restaurant']),
    items: (json['items'] as List<dynamic>?)
        ?.map((e) => CartItemModel.fromJson(e))
        .toList() ??
        [],
    deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
    totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    paymentMethod: json['paymentMethod'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
    deliveredAt: json['deliveredAt'] != null
        ? DateTime.parse(json['deliveredAt'])
        : null,
    note: json['note'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'user': user.toJson(),
    'restaurant': restaurant.toJson(),
    'items': items.map((e) => e.toJson()).toList(),
    'deliveryFee': deliveryFee,
    'totalPrice': totalPrice,
    'paymentMethod': paymentMethod,
    'createdAt': createdAt.toIso8601String(),
    'deliveredAt': deliveredAt?.toIso8601String(),
    'note': note,
  };
}
