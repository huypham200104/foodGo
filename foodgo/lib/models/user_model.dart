import 'address_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final int rewardPoints;
  final List<Map<String, dynamic>> addresses;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.avatarUrl = '',
    this.rewardPoints = 0,
    this.addresses = const [],
  });

  // Getter để truy cập uid (alias cho id)
  String get uid => id;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['uid'] ?? '',
      name: json['name'] ?? json['displayName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'] ?? json['photoURL'] ?? '',
      rewardPoints: json['rewardPoints'] ?? 0,
      addresses: json['addresses'] != null 
          ? List<Map<String, dynamic>>.from(json['addresses'])
          : [],
    );
  }

  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'User',
      email: firebaseUser.email ?? '',
      phone: firebaseUser.phoneNumber ?? '',
      avatarUrl: firebaseUser.photoURL ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'rewardPoints': rewardPoints,
      'addresses': addresses,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    int? rewardPoints,
    List<Map<String, dynamic>>? addresses,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      addresses: addresses ?? this.addresses,
    );
  }
}
