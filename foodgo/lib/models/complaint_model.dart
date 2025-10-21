
import 'user_model.dart';
import 'order_model.dart';


class ComplaintModel {
  final String id;
  final UserModel user;
  final OrderModel order;
  final String reason;
  final String status;
  final DateTime createdAt;

  ComplaintModel({
    required this.id,
    required this.user,
    required this.order,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) => ComplaintModel(
    id: json['id'] ?? '',
    user: UserModel.fromJson(json['user']),
    order: OrderModel.fromJson(json['order']),
    reason: json['reason'] ?? '',
    status: json['status'] ?? 'pending',
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user.toJson(),
    'order': order.toJson(),
    'reason': reason,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };
}