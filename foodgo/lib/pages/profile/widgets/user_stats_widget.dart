import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'user_stat_column.dart';

class UserStatsWidget extends StatelessWidget {
  final int rewardPoints;
  final int totalOrders;
  final String formattedTotalSpent;
  final bool showSeparator;

  const UserStatsWidget({
    super.key,
    required this.rewardPoints,
    required this.totalOrders,
    required this.formattedTotalSpent,
    this.showSeparator = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: UserStatColumn(
            label: 'Điểm thưởng',
            value: '$rewardPoints',
            icon: Icons.monetization_on,
            color: AppColors.warning,
          ),
        ),
        if (showSeparator) _buildSeparator(),
        Expanded(
          child: UserStatColumn(
            label: 'Đơn hàng',
            value: '$totalOrders',
            icon: Icons.shopping_bag,
            color: AppColors.primary,
          ),
        ),
        if (showSeparator) _buildSeparator(),
        Expanded(
          child: UserStatColumn(
            label: 'Chi tiêu',
            value: formattedTotalSpent,
            icon: Icons.account_balance_wallet,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.textLight,
    );
  }
}