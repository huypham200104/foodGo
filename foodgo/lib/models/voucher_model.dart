class VoucherModel {
  final String id;
  final String title;
  final String description;
  final double discountValue;
  final bool freeShip;
  final DateTime expiryDate;
  final String imageUrl;
  final double minOrderValue;
  final String restaurantId;
  final int usageLimit;
  final int usedCount;

  VoucherModel({
    required this.id,
    required this.title,
    required this.description,
    required this.discountValue,
    required this.freeShip,
    required this.expiryDate,
    required this.imageUrl,
    required this.minOrderValue,
    required this.restaurantId,
    required this.usageLimit,
    required this.usedCount,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) => VoucherModel(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    discountValue: (json['discountValue'] ?? 0).toDouble(),
    freeShip: json['freeShip'] ?? false,
    expiryDate: DateTime.parse(json['expiryDate']),
    imageUrl: json['imageUrl'] ?? '',
    minOrderValue: (json['minOrderValue'] ?? 0).toDouble(),
    restaurantId: json['restaurantId'] ?? '',
    usageLimit: json['usageLimit'] ?? 0,
    usedCount: json['usedCount'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'discountValue': discountValue,
    'freeShip': freeShip,
    'expiryDate': expiryDate.toIso8601String(),
    'imageUrl': imageUrl,
    'minOrderValue': minOrderValue,
    'restaurantId': restaurantId,
    'usageLimit': usageLimit,
    'usedCount': usedCount,
  };
}
