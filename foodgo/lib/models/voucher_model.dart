class VoucherModel {
  final String id;
  final String title;
  final String description;
  final double discountValue;
  final bool freeShip;
  final DateTime expiryDate;

  VoucherModel({
    required this.id,
    required this.title,
    required this.description,
    required this.discountValue,
    required this.freeShip,
    required this.expiryDate,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) => VoucherModel(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    discountValue: (json['discountValue'] ?? 0).toDouble(),
    freeShip: json['freeShip'] ?? false,
    expiryDate: DateTime.parse(json['expiryDate']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'discountValue': discountValue,
    'freeShip': freeShip,
    'expiryDate': expiryDate.toIso8601String(),
  };
}
