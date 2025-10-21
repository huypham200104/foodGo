class AddressModel {
  final String id;
  final String label;
  final String detail;
  final double latitude;
  final double longitude;

  AddressModel({
    required this.id,
    required this.label,
    required this.detail,
    required this.latitude,
    required this.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id: json['id'] ?? '',
    label: json['label'] ?? '',
    detail: json['detail'] ?? '',
    latitude: (json['latitude'] ?? 0).toDouble(),
    longitude: (json['longitude'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'detail': detail,
    'latitude': latitude,
    'longitude': longitude,
  };
}
