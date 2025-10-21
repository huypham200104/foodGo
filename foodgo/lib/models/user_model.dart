import 'address_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final int rewardPoints;
  final List<AddressModel> addresses;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    this.rewardPoints = 0,
    this.addresses = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    avatarUrl: json['avatarUrl'] ?? '',
    rewardPoints: json['rewardPoints'] ?? 0,
    addresses: (json['addresses'] as List<dynamic>?)
        ?.map((e) => AddressModel.fromJson(e))
        .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'avatarUrl': avatarUrl,
    'rewardPoints': rewardPoints,
    'addresses': addresses.map((e) => e.toJson()).toList(),
  };
}
