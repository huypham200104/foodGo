import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for user's favorite items
class FavoriteModel {
  final String id; // Document ID (userId)
  final String userId;
  final List<String> favoriteItemIds; // List of menu item IDs
  final DateTime createdAt;
  final DateTime updatedAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.favoriteItemIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create from JSON
  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] ?? json['userId'] ?? '',
      userId: json['userId'] ?? '',
      favoriteItemIds: json['favoriteItemIds'] != null
          ? List<String>.from(json['favoriteItemIds'])
          : [],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'favoriteItemIds': favoriteItemIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Helper method to parse DateTime
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

  /// Copy with method for immutable updates
  FavoriteModel copyWith({
    String? id,
    String? userId,
    List<String>? favoriteItemIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      favoriteItemIds: favoriteItemIds ?? this.favoriteItemIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if item is favorite
  bool isFavorite(String itemId) {
    return favoriteItemIds.contains(itemId);
  }

  /// Get total favorites count
  int get totalFavorites => favoriteItemIds.length;
}

