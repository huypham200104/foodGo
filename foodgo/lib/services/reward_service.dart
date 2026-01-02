import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/reward_model.dart';
import '../utils/tier_system.dart';

class RewardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Get reward for a specific user
  static Future<RewardModel?> getUserReward(String userId) async {
    try {
      debugPrint('🔍 [RewardService] getUserReward() called with userId: "$userId"');
      debugPrint('📂 [RewardService] Querying: rewards/$userId');
      
      final doc = await _firestore
          .collection('rewards')
          .doc(userId)
          .get();
      
      debugPrint('📄 [RewardService] Document exists: ${doc.exists}');
      
      if (doc.exists && doc.data() != null) {
        debugPrint('✅ [RewardService] Document data found');
        final data = doc.data()!;
        debugPrint('📊 [RewardService] Raw data keys: ${data.keys.toList()}');
        debugPrint('📊 [RewardService] UserId in data: ${data['userId']}');
        debugPrint('📊 [RewardService] Points in data: ${data['points']}');
        debugPrint('📊 [RewardService] Tier in data: ${data['tier']}');
        debugPrint('📊 [RewardService] Discount% in data: ${data['discountPercentage']}');
        
        final convertedData = _convertFirestoreData(data);
        debugPrint('🔄 [RewardService] Data converted successfully');
        
        final reward = RewardModel.fromJson(convertedData);
        debugPrint('✅ [RewardService] RewardModel created successfully');
        debugPrint('💰 [RewardService] Tier discount: ${reward.discountPercentage}%');
        return reward;
      }
      
      debugPrint('⚠️  [RewardService] Document does NOT exist or has no data');
      debugPrint('💡 [RewardService] Check Firebase Console: rewards/$userId');
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ [RewardService] Error getting user reward: $e');
      debugPrint('📍 [RewardService] Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Get all rewards (for admin/testing purposes)
  static Future<List<RewardModel>> getAllRewards() async {
    try {
      final snapshot = await _firestore
          .collection('rewards')
          .get();
      
      return snapshot.docs.map((doc) {
        return RewardModel.fromJson(_convertFirestoreData(doc.data()));
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting all rewards: $e');
      rethrow;
    }
  }
  
  /// Update user's reward points and tier
  static Future<void> updateRewardPoints(String userId, int points) async {
    try {
      // Get updated tier info based on new points
      final tierInfo = TierSystem.updateTierInfo(points);
      
      await _firestore
          .collection('rewards')
          .doc(userId)
          .update({
            'points': points,
            'tier': tierInfo['tier'],
            'nextTier': tierInfo['nextTier'],
            'progress': tierInfo['progress'],
            'discountPercentage': tierInfo['discountPercentage'],
            'updatedAt': DateTime.now().toIso8601String(),
          });
      
      debugPrint('✅ Updated reward: points=$points, tier=${tierInfo['tier']}, discount=${tierInfo['discountPercentage']}%');
    } catch (e) {
      debugPrint('❌ Error updating reward points: $e');
      rethrow;
    }
  }
  
  /// Add points to user's reward
  static Future<void> addRewardPoints(String userId, int pointsToAdd) async {
    try {
      final reward = await getUserReward(userId);
      if (reward == null) {
        throw Exception('Reward not found for user');
      }
      
      final newPoints = reward.points + pointsToAdd;
      final newTotalEarned = reward.totalEarned + pointsToAdd;
      
      // Get updated tier info
      final tierInfo = TierSystem.updateTierInfo(newPoints);
      
      await _firestore
          .collection('rewards')
          .doc(userId)
          .update({
            'points': newPoints,
            'totalEarned': newTotalEarned,
            'tier': tierInfo['tier'],
            'nextTier': tierInfo['nextTier'],
            'progress': tierInfo['progress'],
            'discountPercentage': tierInfo['discountPercentage'],
            'updatedAt': DateTime.now().toIso8601String(),
          });
      
      debugPrint('✅ Added $pointsToAdd points. New total: $newPoints, tier: ${tierInfo['tier']}, discount: ${tierInfo['discountPercentage']}%');
    } catch (e) {
      debugPrint('❌ Error adding reward points: $e');
      rethrow;
    }
  }
  
  /// Update user's tier
  static Future<void> updateRewardTier(String userId, String tier, String? nextTier, double progress) async {
    try {
      await _firestore
          .collection('rewards')
          .doc(userId)
          .update({
            'tier': tier,
            'nextTier': nextTier,
            'progress': progress,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('❌ Error updating reward tier: $e');
      rethrow;
    }
  }
  
  /// Create initial reward for new user
  static Future<void> createUserReward(String userId) async {
    try {
      final reward = RewardModel(
        userId: userId,
        points: 0,
        tier: 'New',
        totalEarned: 0,
        totalRedeemed: 0,
        active: true,
        nextTier: 'Bronze',
        progress: 0.0,
        updatedAt: DateTime.now().toIso8601String(),
        redeemableVouchers: [],
      );
      
      await _firestore
          .collection('rewards')
          .doc(userId)
          .set(reward.toJson());
    } catch (e) {
      debugPrint('❌ Error creating user reward: $e');
      rethrow;
    }
  }
  
  /// Redeem points for voucher
  static Future<void> redeemPoints(String userId, int pointsToRedeem) async {
    try {
      final reward = await getUserReward(userId);
      if (reward == null) {
        throw Exception('Reward not found for user');
      }
      
      if (reward.points < pointsToRedeem) {
        throw Exception('Insufficient points');
      }
      
      await _firestore
          .collection('rewards')
          .doc(userId)
          .update({
            'points': FieldValue.increment(-pointsToRedeem),
            'totalRedeemed': FieldValue.increment(pointsToRedeem),
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('❌ Error redeeming points: $e');
      rethrow;
    }
  }
  
  /// Stream user reward (for real-time updates)
  static Stream<RewardModel?> streamUserReward(String userId) {
    return _firestore
        .collection('rewards')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return RewardModel.fromJson(_convertFirestoreData(doc.data()!));
          }
          return null;
        });
  }
  
  /// Convert Firestore Timestamp to ISO8601 String
  static Map<String, dynamic> _convertFirestoreData(Map<String, dynamic> data) {
    Map<String, dynamic> converted = {};
    data.forEach((key, value) {
      if (value is Timestamp) {
        converted[key] = value.toDate().toIso8601String();
      } else {
        converted[key] = value;
      }
    });
    return converted;
  }
}

