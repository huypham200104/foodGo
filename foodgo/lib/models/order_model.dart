import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';
import 'restaurant_model.dart';
import 'address_model.dart';

class OrderModel {
  final String id;
  final String status;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final String? restaurantImage;
  final List<CartItemModel> items;
  final double deliveryFee;
  final double totalPrice;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String note;
  final AddressModel? deliveryAddress;
  final int? estimatedDeliveryTime;
  final double? rating;
  final String? review;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final DateTime? updatedAt;

  // Constructor chính
  OrderModel({
    required this.id,
    required this.status,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantImage,
    required this.items,
    required this.deliveryFee,
    required this.totalPrice,
    required this.paymentMethod,
    required this.createdAt,
    this.deliveredAt,
    this.note = '',
    this.deliveryAddress,
    this.estimatedDeliveryTime,
    this.rating,
    this.review,
    this.cancelReason,
    this.cancelledAt,
    this.updatedAt,
  });

  // Factory constructor để tạo order mới từ checkout
  factory OrderModel.fromCheckout({
    required String userId,
    required RestaurantModel restaurant,
    required List<CartItemModel> items,
    required double totalPrice,
    required double deliveryFee,
    required String paymentMethod,
    required AddressModel deliveryAddress,
    String note = '',
    int? estimatedDeliveryTime,
  }) {
    return OrderModel(
      id: '', // Will be set by Firestore
      status: 'pending',
      userId: userId,
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      restaurantImage: restaurant.imageUrl,
      items: items,
      deliveryFee: deliveryFee,
      totalPrice: totalPrice,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      note: note,
      deliveryAddress: deliveryAddress,
      estimatedDeliveryTime: estimatedDeliveryTime ?? 30,
    );
  }

  // Getter cho tổng tiền bao gồm phí giao hàng
  double get totalAmount => totalPrice + deliveryFee;

  // Getter cho tổng tiền đã format
  String get formattedTotal => '${totalPrice.toStringAsFixed(0)}đ';

  // Getter cho tổng tiền + phí giao hàng đã format
  String get formattedTotalWithDelivery => '${totalAmount.toStringAsFixed(0)}đ';

  // Getter cho địa chỉ giao hàng dạng string
  String get deliveryAddressString {
    return deliveryAddress?.displayAddress ?? 'Không có địa chỉ';
  }

  // Getter cho địa chỉ giao hàng ngắn
  String get shortDeliveryAddress {
    return deliveryAddress?.shortAddress ?? 'Không có địa chỉ';
  }

  // Getter cho thông tin giao hàng đầy đủ
  String get fullDeliveryInfo {
    return deliveryAddress?.deliveryDisplay ?? 'Không có thông tin giao hàng';
  }

  // Getter for delivery location name
  String get deliveryLocationName {
    return deliveryAddress?.safeName ?? 'Địa chỉ giao hàng';
  }

  // Getter for delivery phone
  String get deliveryPhone {
    return deliveryAddress?.phone ?? '';
  }

  // Kiểm tra có thể hủy không
  bool get canCancel {
    return ['pending', 'confirmed'].contains(status);
  }

  // Kiểm tra có thể đánh giá không
  bool get canRate {
    return status == 'delivered' && rating == null;
  }

  // Kiểm tra có thể đặt lại không
  bool get canReorder {
    return ['delivered', 'cancelled'].contains(status);
  }

  // Kiểm tra có thể theo dõi không
  bool get canTrack {
    return ['confirmed', 'preparing', 'on_delivery'].contains(status);
  }

  // Get order status display text
  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'preparing':
        return 'Đang chuẩn bị';
      case 'on_delivery':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Đã giao hàng';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  // Get order status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'orange';
      case 'confirmed':
        return 'blue';
      case 'preparing':
        return 'purple';
      case 'on_delivery':
        return 'indigo';
      case 'delivered':
        return 'green';
      case 'cancelled':
        return 'red';
      default:
        return 'gray';
    }
  }

  // Get estimated delivery text
  String get estimatedDeliveryText {
    if (estimatedDeliveryTime == null) return 'Chưa xác định';
    return '$estimatedDeliveryTime phút';
  }

  // Get formatted order date
  String get formattedOrderDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  // Get formatted order time
  String get formattedOrderTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  // Get order datetime display
  String get orderDateTimeDisplay {
    return '$formattedOrderDate lúc $formattedOrderTime';
  }

  // Create from Firestore
  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      status: data['status'] ?? 'pending',
      userId: data['userId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      restaurantImage: data['restaurantImage'],
      items: (data['items'] as List<dynamic>?)
          ?.where((e) => e != null && e is Map)
          .map((e) {
            try {
              return CartItemModel.fromJson(Map<String, dynamic>.from(e as Map));
            } catch (_) {
              return null;
            }
          })
          .whereType<CartItemModel>()
          .toList() ?? [],
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? 'cash',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
      note: data['note'] ?? '',
      deliveryAddress: data['deliveryAddress'] != null && data['deliveryAddress'] is Map<String, dynamic>
          ? AddressModel.fromJson(data['deliveryAddress'])
          : null,
      estimatedDeliveryTime: _parseInt(data['estimatedDeliveryTime']),
      rating: data['rating']?.toDouble(),
      review: data['review'],
      cancelReason: data['cancelReason'],
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      'status': status,
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'restaurantImage': restaurantImage,
      'items': items.map((e) => e.toJson()).toList(),
      'deliveryFee': deliveryFee,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
      'note': note,
      'deliveryAddress': deliveryAddress?.toJson(),
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'rating': rating,
      'review': review,
      'cancelReason': cancelReason,
    };

    if (deliveredAt != null) {
      data['deliveredAt'] = Timestamp.fromDate(deliveredAt!);
    }
    if (cancelledAt != null) {
      data['cancelledAt'] = Timestamp.fromDate(cancelledAt!);
    }
    if (updatedAt != null) {
      data['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }

    return data;
  }

  /// Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is DateTime) return value;
    return null;
  }

  /// Helper method to parse int safely
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] ?? '',
    status: json['status'] ?? 'pending',
    userId: json['userId'] ?? '',
    restaurantId: json['restaurantId'] ?? '',
    restaurantName: json['restaurantName'] ?? '',
    restaurantImage: json['restaurantImage'],
    items: (json['items'] as List<dynamic>?)
        ?.where((e) => e != null && e is Map<String, dynamic>)
        .map((e) {
          try {
            return CartItemModel.fromJson(e as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<CartItemModel>()
        .toList() ?? [],
    deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
    totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    paymentMethod: json['paymentMethod'] ?? 'cash',
    createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
    deliveredAt: _parseDateTime(json['deliveredAt']),
    note: json['note'] ?? '',
    deliveryAddress: json['deliveryAddress'] != null 
        ? AddressModel.fromJson(json['deliveryAddress'])
        : null,
    estimatedDeliveryTime: _parseInt(json['estimatedDeliveryTime']),
    rating: json['rating']?.toDouble(),
    review: json['review'],
    cancelReason: json['cancelReason'],
    cancelledAt: _parseDateTime(json['cancelledAt']),
    updatedAt: _parseDateTime(json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'userId': userId,
    'restaurantId': restaurantId,
    'restaurantName': restaurantName,
    'restaurantImage': restaurantImage,
    'items': items.map((e) => e.toJson()).toList(),
    'deliveryFee': deliveryFee,
    'totalPrice': totalPrice,
    'paymentMethod': paymentMethod,
    'createdAt': createdAt.toIso8601String(),
    'deliveredAt': deliveredAt?.toIso8601String(),
    'note': note,
    'deliveryAddress': deliveryAddress?.toJson(),
    'estimatedDeliveryTime': estimatedDeliveryTime,
    'rating': rating,
    'review': review,
    'cancelReason': cancelReason,
    'cancelledAt': cancelledAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  // Copy with method
  OrderModel copyWith({
    String? id,
    String? status,
    String? userId,
    String? restaurantId,
    String? restaurantName,
    String? restaurantImage,
    List<CartItemModel>? items,
    double? deliveryFee,
    double? totalPrice,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? deliveredAt,
    String? note,
    AddressModel? deliveryAddress,
    int? estimatedDeliveryTime,
    double? rating,
    String? review,
    String? cancelReason,
    DateTime? cancelledAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantImage: restaurantImage ?? this.restaurantImage,
      items: items ?? this.items,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      note: note ?? this.note,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      cancelReason: cancelReason ?? this.cancelReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, status: $status, restaurantName: $restaurantName, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
