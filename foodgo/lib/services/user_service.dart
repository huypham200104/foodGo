import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:foodgo/models/user_model.dart';

class UserService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy current user (merge Firebase Auth + Firestore)
  static Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      // Get additional data from Firestore
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        // Merge Firebase Auth + Firestore data
        return UserModel.fromFirebaseUserWithData(firebaseUser, doc.data());
      } else {
        // First time login - create user profile
        final newUser = UserModel.fromFirebaseUser(firebaseUser);
        await createUserProfile(newUser);
        return newUser;
      }
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// Tạo user profile trong Firestore (sau khi đăng ký thành công)
  static Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toFirestoreJson());
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestoreJson());
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Update specific field
  static Future<void> updateUserField(String userId, String field, dynamic value) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
            field: value,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('Error updating user field: $e');
      rethrow;
    }
  }

  /// Add reward points
  static Future<void> addRewardPoints(String userId, int points) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
            'rewardPoints': FieldValue.increment(points),
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('Error adding reward points: $e');
      rethrow;
    }
  }

  /// Update membership level
  static Future<void> updateMembershipLevel(String userId, String level) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
            'membershipLevel': level,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('Error updating membership level: $e');
      rethrow;
    }
  }

  /// Add to favorites
  static Future<void> addToFavorites(String userId, String itemId, {bool isRestaurant = false}) async {
    try {
      final field = isRestaurant ? 'favoriteRestaurants' : 'favoriteItems';
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
            field: FieldValue.arrayUnion([itemId]),
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      rethrow;
    }
  }

  /// Remove from favorites
  static Future<void> removeFromFavorites(String userId, String itemId, {bool isRestaurant = false}) async {
    try {
      final field = isRestaurant ? 'favoriteRestaurants' : 'favoriteItems';
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
            field: FieldValue.arrayRemove([itemId]),
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
      rethrow;
    }
  }

  /// Update order stats (sau khi order thành công)
  static Future<void> updateOrderStats(String userId, double orderValue) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return;

      final newTotalSpent = user.totalSpent + orderValue;
      final newTotalOrders = user.totalOrders + 1;
      
      // Calculate new membership level
      String newMembershipLevel = user.membershipLevel;
      if (newTotalSpent >= 5000000) {
        newMembershipLevel = 'Gold';
      } else if (newTotalSpent >= 2000000) {
        newMembershipLevel = 'Silver';
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .update({
            'totalOrders': newTotalOrders,
            'totalSpent': newTotalSpent,
            'lastOrderDate': DateTime.now().toIso8601String(),
            'membershipLevel': newMembershipLevel,
            'updatedAt': DateTime.now().toIso8601String(),
          });

      // Add reward points (1 point per 1000 VND)
      final rewardPoints = (orderValue / 1000).floor();
      if (rewardPoints > 0) {
        await addRewardPoints(userId, rewardPoints);
      }
    } catch (e) {
      debugPrint('Error updating order stats: $e');
      rethrow;
    }
  }

  /// Delete user account
  static Future<void> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Delete Firestore document
      await _firestore
          .collection('users')
          .doc(user.uid)
          .delete();

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      debugPrint('Error deleting user account: $e');
      rethrow;
    }
  }
}

