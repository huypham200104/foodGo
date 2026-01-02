import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/cart_item_model.dart';

class RewardCalculator {
  static const int pointsPerUnit = 1000; // 1000 VND = 1 Point

  /// Calculate points earned from an order
  static int calculateEarnedPoints(OrderModel order, UserModel user) {
    // 1. Base Points
    // Use totalPrice (after discount?) or totalAmount (with shipping?).
    // Usually points are on subtotal (totalPrice).
    // Formula: floor(Price / 1000)
    double baseValue = order.totalPrice;
    int basePoints = (baseValue / pointsPerUnit).floor();

    // 2. Category Multiplier
    double categoryMultiplier = _getCategoryMultiplier(order.items);

    // 3. Tier Bonus
    double tierBonus = _getTierBonus(user.membershipLevel);

    // 4. Final Calculation
    // Formula: Base * Category * (1 + TierBonus)
    // Note: The formula in markdown was: Base * Category * (1 + TierBonus)
    // Let's follow that.
    double totalPoints = basePoints * categoryMultiplier * (1 + tierBonus);

    return totalPoints.floor();
  }

  /// Get the highest multiplier based on items in the order
  static double _getCategoryMultiplier(List<CartItemModel> items) {
    bool hasCombo = false;
    bool hasNewItem = false;

    for (var item in items) {
      if (item.item.category.toLowerCase() == 'combo') {
        hasCombo = true;
      }
      if (item.item.isNew) {
        hasNewItem = true;
      }
    }

    if (hasCombo) return 1.2;
    if (hasNewItem) return 1.1;
    return 1.0;
  }

  /// Get bonus percentage based on tier
  static double _getTierBonus(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return 0.15; // +15%
      case 'gold':
        return 0.10; // +10%
      case 'silver':
        return 0.05; // +5%
      case 'bronze':
      case 'new':
      default:
        return 0.0;
    }
  }

  /// Determine next tier based on total earned points
  static String calculateTier(int totalEarnedPoints) {
    if (totalEarnedPoints >= 2000) return 'Platinum';
    if (totalEarnedPoints >= 1000) return 'Gold';
    if (totalEarnedPoints >= 300) return 'Silver';
    return 'Bronze';
  }
  
  /// Get progress to next tier (0.0 to 1.0)
  static double calculateTierProgress(int totalEarnedPoints) {
    if (totalEarnedPoints >= 2000) return 1.0; // Max tier
    
    if (totalEarnedPoints >= 1000) {
      // Gold -> Platinum (1000 -> 2000)
      return (totalEarnedPoints - 1000) / 1000;
    }
    
    if (totalEarnedPoints >= 300) {
      // Silver -> Gold (300 -> 1000)
      return (totalEarnedPoints - 300) / 700;
    }
    
    // Bronze -> Silver (0 -> 300)
    return totalEarnedPoints / 300;
  }
}

