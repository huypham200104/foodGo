import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/favorite_model.dart';
import '../models/menu_item_model.dart';

/// Service for managing user's favorite items
class FavoriteService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  static String? get _currentUserId => _auth.currentUser?.uid;

  /// Collection reference
  static CollectionReference get _favoritesCollection =>
      _firestore.collection('favorites');

  /// Get user's favorites
  static Future<FavoriteModel?> getUserFavorites([String? userId]) async {
    try {
      final uid = userId ?? _currentUserId;
      if (uid == null) {
        debugPrint('No user logged in');
        return null;
      }

      final doc = await _favoritesCollection.doc(uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return FavoriteModel.fromJson(data);
      } else {
        // Create empty favorites for new user
        return FavoriteModel(
          id: uid,
          userId: uid,
          favoriteItemIds: [],
        );
      }
    } catch (e) {
      debugPrint('Error getting user favorites: $e');
      return null;
    }
  }

  /// Add item to favorites
  static Future<bool> addToFavorites(String itemId) async {
    try {
      final uid = _currentUserId;
      if (uid == null) {
        debugPrint('No user logged in');
        return false;
      }

      await _favoritesCollection.doc(uid).set({
        'userId': uid,
        'favoriteItemIds': FieldValue.arrayUnion([itemId]),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // Also update user's favoriteItems
      await _firestore.collection('users').doc(uid).update({
        'favoriteItems': FieldValue.arrayUnion([itemId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Added item $itemId to favorites');
      return true;
    } catch (e) {
      debugPrint('❌ Error adding to favorites: $e');
      return false;
    }
  }

  /// Remove item from favorites
  static Future<bool> removeFromFavorites(String itemId) async {
    try {
      final uid = _currentUserId;
      if (uid == null) {
        debugPrint('No user logged in');
        return false;
      }

      await _favoritesCollection.doc(uid).update({
        'favoriteItemIds': FieldValue.arrayRemove([itemId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Also update user's favoriteItems
      await _firestore.collection('users').doc(uid).update({
        'favoriteItems': FieldValue.arrayRemove([itemId]),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Removed item $itemId from favorites');
      return true;
    } catch (e) {
      debugPrint('❌ Error removing from favorites: $e');
      return false;
    }
  }

  /// Toggle favorite status
  static Future<bool> toggleFavorite(String itemId) async {
    try {
      final favorites = await getUserFavorites();
      if (favorites == null) return false;

      if (favorites.isFavorite(itemId)) {
        return await removeFromFavorites(itemId);
      } else {
        return await addToFavorites(itemId);
      }
    } catch (e) {
      debugPrint('❌ Error toggling favorite: $e');
      return false;
    }
  }

  /// Check if item is favorite
  static Future<bool> isFavorite(String itemId) async {
    try {
      final favorites = await getUserFavorites();
      return favorites?.isFavorite(itemId) ?? false;
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
      return false;
    }
  }

  /// Get all favorite items with details
  static Future<List<MenuItemModel>> getFavoriteItems() async {
    try {
      final favorites = await getUserFavorites();
      if (favorites == null || favorites.favoriteItemIds.isEmpty) {
        return [];
      }

      // Fetch menu items details
      List<MenuItemModel> items = [];
      
      for (String itemId in favorites.favoriteItemIds) {
        try {
          final doc = await _firestore
              .collection('menu_items')
              .doc(itemId)
              .get();

          if (doc.exists) {
            final data = doc.data();
            if (data != null) {
              data['id'] = doc.id;
              items.add(MenuItemModel.fromJson(data));
            }
          }
        } catch (e) {
          debugPrint('Error fetching item $itemId: $e');
        }
      }

      return items;
    } catch (e) {
      debugPrint('Error getting favorite items: $e');
      return [];
    }
  }

  /// Clear all favorites for current user
  static Future<bool> clearAllFavorites() async {
    try {
      final uid = _currentUserId;
      if (uid == null) {
        debugPrint('No user logged in');
        return false;
      }

      await _favoritesCollection.doc(uid).update({
        'favoriteItemIds': [],
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await _firestore.collection('users').doc(uid).update({
        'favoriteItems': [],
        'updatedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Cleared all favorites');
      return true;
    } catch (e) {
      debugPrint('❌ Error clearing favorites: $e');
      return false;
    }
  }

  /// Get favorites count
  static Future<int> getFavoritesCount() async {
    try {
      final favorites = await getUserFavorites();
      return favorites?.totalFavorites ?? 0;
    } catch (e) {
      debugPrint('Error getting favorites count: $e');
      return 0;
    }
  }

  /// Listen to favorites changes (Stream)
  static Stream<FavoriteModel?> watchUserFavorites([String? userId]) {
    final uid = userId ?? _currentUserId;
    if (uid == null) {
      return Stream.value(null);
    }

    return _favoritesCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return FavoriteModel.fromJson(data);
      }
      return null;
    });
  }
}


