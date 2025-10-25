class AddressModel {
  final String id;
  final String label;
  final String detail;
  final double latitude;
  final double longitude;
  final String userId;
  final bool isDefault;
  final String city;
  final String ward;

  AddressModel({
    required this.id,
    required this.label,
    required this.detail,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.isDefault,
    required this.city,
    required this.ward,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id: json['id'] ?? '',
    label: json['label'] ?? '',
    detail: json['detail'] ?? '',
    latitude: (json['latitude'] ?? 0).toDouble(),
    longitude: (json['longitude'] ?? 0).toDouble(),
    userId: json['userId'] ?? '',
    isDefault: json['isDefault'] ?? false,
    city: json['city'] ?? '',
    ward: json['ward'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'detail': detail,
    'latitude': latitude,
    'longitude': longitude,
    'userId': userId,
    'isDefault': isDefault,
    'city': city,
    'ward': ward,
  };
}
