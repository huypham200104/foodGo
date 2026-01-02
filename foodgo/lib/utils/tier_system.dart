/// Tier configuration with discount percentages and point thresholds
class TierConfig {
  final String name;
  final int minPoints;
  final int? maxPoints;
  final double discountPercentage; // % giảm giá trên mỗi đơn hàng
  final String? nextTier;
  final List<String> benefits;

  const TierConfig({
    required this.name,
    required this.minPoints,
    this.maxPoints,
    required this.discountPercentage,
    this.nextTier,
    required this.benefits,
  });
}

/// Tier system configuration
class TierSystem {
  static const List<TierConfig> tiers = [
    TierConfig(
      name: 'New',
      minPoints: 0,
      maxPoints: 199,
      discountPercentage: 0, // Không giảm giá
      nextTier: 'Bronze',
      benefits: [
        'Tích điểm cho mọi đơn hàng',
        'Nhận thông báo về khuyến mãi',
      ],
    ),
    TierConfig(
      name: 'Bronze',
      minPoints: 200,
      maxPoints: 499,
      discountPercentage: 5, // Giảm 5% mỗi đơn
      nextTier: 'Silver',
      benefits: [
        'Giảm 5% cho mọi đơn hàng',
        'Tích điểm cho mọi đơn hàng',
        'Nhận thông báo về khuyến mãi',
      ],
    ),
    TierConfig(
      name: 'Silver',
      minPoints: 500,
      maxPoints: 999,
      discountPercentage: 10, // Giảm 10% mỗi đơn
      nextTier: 'Gold',
      benefits: [
        'Giảm 10% cho mọi đơn hàng',
        'Miễn phí giao hàng cho đơn từ 300K',
        'Voucher giảm giá theo mùa',
        'Tích điểm x1.2 cho mọi đơn hàng',
      ],
    ),
    TierConfig(
      name: 'Gold',
      minPoints: 1000,
      maxPoints: 1999,
      discountPercentage: 15, // Giảm 15% mỗi đơn
      nextTier: 'Platinum',
      benefits: [
        'Giảm 15% cho mọi đơn hàng',
        'Miễn phí giao hàng cho đơn từ 200K',
        'Voucher giảm giá đặc biệt',
        'Tích điểm x1.5 cho mọi đơn hàng',
      ],
    ),
    TierConfig(
      name: 'Platinum',
      minPoints: 2000,
      maxPoints: null,
      discountPercentage: 20, // Giảm 20% mỗi đơn
      nextTier: null,
      benefits: [
        'Giảm 20% cho mọi đơn hàng',
        'Miễn phí giao hàng không giới hạn',
        'Ưu tiên hỗ trợ khách hàng VIP',
        'Voucher giảm giá đặc biệt hàng tháng',
        'Tích điểm gấp đôi cho mọi đơn hàng',
      ],
    ),
  ];

  /// Get tier config by name
  static TierConfig? getTierByName(String tierName) {
    try {
      return tiers.firstWhere(
        (tier) => tier.name.toLowerCase() == tierName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get tier config by points
  static TierConfig getTierByPoints(int points) {
    for (var tier in tiers.reversed) {
      if (points >= tier.minPoints) {
        return tier;
      }
    }
    return tiers.first; // Default to 'New'
  }

  /// Calculate discount percentage for a tier
  static double getDiscountPercentage(String tierName) {
    final tier = getTierByName(tierName);
    return tier?.discountPercentage ?? 0.0;
  }

  /// Calculate progress to next tier
  static double calculateProgress(int currentPoints, String currentTier) {
    final tier = getTierByName(currentTier);
    if (tier == null || tier.nextTier == null) return 1.0;

    final nextTier = getTierByName(tier.nextTier!);
    if (nextTier == null) return 1.0;

    final pointsInCurrentTier = currentPoints - tier.minPoints;
    final pointsNeededForNextTier = nextTier.minPoints - tier.minPoints;

    if (pointsNeededForNextTier <= 0) return 1.0;

    return (pointsInCurrentTier / pointsNeededForNextTier).clamp(0.0, 1.0);
  }

  /// Update tier based on points
  static Map<String, dynamic> updateTierInfo(int points) {
    final tier = getTierByPoints(points);
    final progress = calculateProgress(points, tier.name);

    return {
      'tier': tier.name,
      'nextTier': tier.nextTier,
      'progress': progress,
      'discountPercentage': tier.discountPercentage,
    };
  }
}

