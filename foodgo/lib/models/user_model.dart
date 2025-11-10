import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final int rewardPoints;
  final List<Map<String, dynamic>> addresses;
  
  // ✨ Thêm thuộc tính cho food delivery
  final String membershipLevel;
  final int totalOrders;
  final double totalSpent;
  final DateTime? lastOrderDate;
  final List<String> favoriteRestaurants;
  final List<String> favoriteItems;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.avatarUrl = '',
    this.rewardPoints = 0,
    this.addresses = const [],
    // ✨ Thêm parameters mới
    this.membershipLevel = 'Bronze',
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.lastOrderDate,
    this.favoriteRestaurants = const [],
    this.favoriteItems = const [],
    this.preferences = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

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
      // ✨ Parse thuộc tính mới
      membershipLevel: json['membershipLevel'] ?? 'Bronze',
      totalOrders: json['totalOrders'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0.0).toDouble(),
      lastOrderDate: json['lastOrderDate'] != null 
          ? _parseDateTime(json['lastOrderDate'])
          : null,
      favoriteRestaurants: json['favoriteRestaurants'] != null
          ? List<String>.from(json['favoriteRestaurants'])
          : [],
      favoriteItems: json['favoriteItems'] != null
          ? List<String>.from(json['favoriteItems'])
          : [],
      preferences: json['preferences'] ?? {},
      createdAt: json['createdAt'] != null
          ? _parseDateTime(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? _parseDateTime(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // ✨ Factory từ Firebase User (sau khi đăng ký/đăng nhập thành công)
  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? _extractNameFromEmail(firebaseUser.email ?? ''),
      email: firebaseUser.email ?? '',
      phone: firebaseUser.phoneNumber ?? '',
      avatarUrl: firebaseUser.photoURL ?? '',
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // ✨ Helper method để lấy tên từ email
  static String _extractNameFromEmail(String email) {
    if (email.isEmpty) return 'User';
    return email.split('@')[0];
  }

  // ✨ Helper method để parse DateTime từ Timestamp hoặc String
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  // ✨ Factory để merge Firebase User + Firestore data
  factory UserModel.fromFirebaseUserWithData(User firebaseUser, Map<String, dynamic>? firestoreData) {
    return UserModel(
      id: firebaseUser.uid,
      name: firestoreData?['name'] ?? firebaseUser.displayName ?? _extractNameFromEmail(firebaseUser.email ?? ''),
      email: firebaseUser.email ?? '',
      phone: firestoreData?['phone'] ?? firebaseUser.phoneNumber ?? '',
      avatarUrl: firestoreData?['avatarUrl'] ?? firebaseUser.photoURL ?? '',
      rewardPoints: firestoreData?['rewardPoints'] ?? 0,
      addresses: firestoreData?['addresses'] != null 
          ? List<Map<String, dynamic>>.from(firestoreData!['addresses'])
          : [],
      membershipLevel: firestoreData?['membershipLevel'] ?? 'Bronze',
      totalOrders: firestoreData?['totalOrders'] ?? 0,
      totalSpent: (firestoreData?['totalSpent'] ?? 0.0).toDouble(),
      lastOrderDate: firestoreData?['lastOrderDate'] != null 
          ? _parseDateTime(firestoreData!['lastOrderDate'])
          : null,
      favoriteRestaurants: firestoreData?['favoriteRestaurants'] != null
          ? List<String>.from(firestoreData!['favoriteRestaurants'])
          : [],
      favoriteItems: firestoreData?['favoriteItems'] != null
          ? List<String>.from(firestoreData!['favoriteItems'])
          : [],
      preferences: firestoreData?['preferences'] ?? {},
      createdAt: firestoreData?['createdAt'] != null
          ? _parseDateTime(firestoreData!['createdAt'])
          : (firebaseUser.metadata.creationTime ?? DateTime.now()),
      updatedAt: firestoreData?['updatedAt'] != null
          ? _parseDateTime(firestoreData!['updatedAt'])
          : DateTime.now(),
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
      // ✨ Thêm vào JSON
      'membershipLevel': membershipLevel,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'lastOrderDate': lastOrderDate?.toIso8601String(),
      'favoriteRestaurants': favoriteRestaurants,
      'favoriteItems': favoriteItems,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ✨ Method để sync với Firebase User profile
  Map<String, dynamic> toFirestoreJson() {
    return {
      'name': name,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'rewardPoints': rewardPoints,
      'addresses': addresses,
      'membershipLevel': membershipLevel,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'lastOrderDate': lastOrderDate?.toIso8601String(),
      'favoriteRestaurants': favoriteRestaurants,
      'favoriteItems': favoriteItems,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
    // ✨ Thêm parameters cho copyWith
    String? membershipLevel,
    int? totalOrders,
    double? totalSpent,
    DateTime? lastOrderDate,
    List<String>? favoriteRestaurants,
    List<String>? favoriteItems,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      addresses: addresses ?? this.addresses,
      // ✨ Copy thuộc tính mới
      membershipLevel: membershipLevel ?? this.membershipLevel,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      favoriteRestaurants: favoriteRestaurants ?? this.favoriteRestaurants,
      favoriteItems: favoriteItems ?? this.favoriteItems,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(), // Always update timestamp
    );
  }

  // ✨ Business logic methods
  
  /// Get membership benefits
  Map<String, dynamic> get membershipBenefits {
    switch (membershipLevel) {
      case 'Gold':
        return {'discount': 15, 'freeDelivery': true, 'prioritySupport': true};
      case 'Silver':
        return {'discount': 10, 'freeDelivery': true, 'prioritySupport': false};
      case 'Bronze':
      default:
        return {'discount': 5, 'freeDelivery': false, 'prioritySupport': false};
    }
  }

  /// Calculate next membership level
  String get nextMembershipLevel {
    if (totalSpent >= 5000000) return 'Gold';
    if (totalSpent >= 2000000) return 'Silver';
    return 'Bronze';
  }

  /// Check if user can get free delivery
  bool get canGetFreeDelivery {
    return membershipBenefits['freeDelivery'] == true;
  }

  /// Get user's discount percentage
  int get discountPercentage {
    return membershipBenefits['discount'] ?? 0;
  }

  /// Format total spent
  String get formattedTotalSpent {
    return '${totalSpent.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    )}đ';
  }

  /// Get user level progress
  double get membershipProgress {
    if (membershipLevel == 'Gold') return 1.0;
    if (membershipLevel == 'Silver') return (totalSpent / 5000000).clamp(0.0, 1.0);
    return (totalSpent / 2000000).clamp(0.0, 1.0);
  }

  /// Check if user is active (ordered in last 30 days)
  bool get isActiveUser {
    if (lastOrderDate == null) return false;
    return DateTime.now().difference(lastOrderDate!).inDays <= 30;
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty && 
           phone.isNotEmpty && 
           addresses.isNotEmpty;
  }

  /// Get display name (fallback to email if name is empty)
  String get displayName {
    if (name.isNotEmpty) return name;
    return _extractNameFromEmail(email);
  }
}