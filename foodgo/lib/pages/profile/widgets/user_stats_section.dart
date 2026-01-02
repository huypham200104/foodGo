import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../models/user_model.dart';
import 'user_stat_item.dart';

class UserStatsSection extends StatelessWidget {
  final UserModel user;

  const UserStatsSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
        border: Border.all(color: AppColors.textLight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin thành viên',
            style: TextStyle(
              fontSize: screen.ScreenService.mediumText,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: screen.ScreenService.smallSpacing),
          
          Row(
            children: [
              Expanded(
                child: UserStatItem(
                  label: 'Hạng thành viên',
                  value: user.membershipLevel,
                  icon: Icons.star,
                  color: _getMembershipColor(user.membershipLevel),
                ),
              ),
              SizedBox(width: screen.ScreenService.smallSpacing),
              Expanded(
                child: UserStatItem(
                  label: 'Tổng đơn hàng',
                  value: '${user.totalOrders}',
                  icon: Icons.shopping_bag,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: screen.ScreenService.smallSpacing),
          
          UserStatItem(
            label: 'Điểm thưởng',
            value: '${user.rewardPoints}',
            icon: Icons.monetization_on,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Color _getMembershipColor(String level) {
    switch (level) {
      case 'Gold':
        return const Color(0xFFFFD700);
      case 'Silver':
        return const Color(0xFFC0C0C0);
      case 'Bronze':
      default:
        return const Color(0xFFCD7F32);
    }
  }
}

