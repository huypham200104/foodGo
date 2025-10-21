import 'voucher_model.dart';

class RewardModel {
  final int points;
  final String tier;
  final List<VoucherModel> redeemableVouchers;

  RewardModel({
    required this.points,
    required this.tier,
    this.redeemableVouchers = const [],
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) => RewardModel(
    points: json['points'] ?? 0,
    tier: json['tier'] ?? 'Bronze',
    redeemableVouchers: (json['redeemableVouchers'] as List?)
        ?.map((e) => VoucherModel.fromJson(e))
        .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'points': points,
    'tier': tier,
    'redeemableVouchers':
    redeemableVouchers.map((e) => e.toJson()).toList(),
  };
}
