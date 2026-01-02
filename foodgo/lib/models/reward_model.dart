import 'voucher_model.dart';

class RewardModel {
  final int points;
  final String tier;
  final List<VoucherModel> redeemableVouchers;
  final String userId;
  final String updatedAt;
  final int totalEarned;
  final int totalRedeemed;
  final bool active;
  final String? nextTier;
  final double progress;
  final double discountPercentage; // % giảm giá theo hạng (0-100)

  RewardModel({
    required this.points,
    required this.tier,
    this.redeemableVouchers = const [],
    required this.userId,
    required this.updatedAt,
    required this.totalEarned,
    required this.totalRedeemed,
    required this.active,
    this.nextTier,
    required this.progress,
    this.discountPercentage = 0.0,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) => RewardModel(
    points: json['points'] ?? 0,
    tier: json['tier'] ?? 'Bronze',
    redeemableVouchers: (json['redeemableVouchers'] as List?)
        ?.map((e) => VoucherModel.fromJson(e))
        .toList() ??
        [],
    userId: json['userId'] ?? '',
    updatedAt: json['updatedAt'] ?? '',
    totalEarned: json['totalEarned'] ?? 0,
    totalRedeemed: json['totalRedeemed'] ?? 0,
    active: json['active'] ?? false,
    nextTier: json['nextTier'],
    progress: (json['progress'] ?? 0.0).toDouble(),
    discountPercentage: (json['discountPercentage'] ?? 0.0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'points': points,
    'tier': tier,
    'redeemableVouchers': redeemableVouchers.map((e) => e.toJson()).toList(),
    'userId': userId,
    'updatedAt': updatedAt,
    'totalEarned': totalEarned,
    'totalRedeemed': totalRedeemed,
    'active': active,
    'nextTier': nextTier,
    'progress': progress,
    'discountPercentage': discountPercentage,
  };
  
  /// Get discount amount for a given order total
  double getDiscountAmount(double orderTotal) {
    return orderTotal * (discountPercentage / 100);
  }
  
  /// Get final price after tier discount
  double getFinalPrice(double orderTotal) {
    return orderTotal - getDiscountAmount(orderTotal);
  }
}


