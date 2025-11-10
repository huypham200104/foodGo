import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../models/user_model.dart';
import 'user_info_header.dart';
import 'user_stats_widget.dart';

class ProfileInfoWidget extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const ProfileInfoWidget({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(screen.ScreenService.mediumSpacing),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // User info header
          UserInfoHeader(user: user, onTap: onTap),
          
          SizedBox(height: screen.ScreenService.mediumSpacing),
          
          // Stats row
          UserStatsWidget(
            rewardPoints: user.rewardPoints,
            totalOrders: user.totalOrders,
            formattedTotalSpent: user.formattedTotalSpent,
          ),
          
          SizedBox(height: screen.ScreenService.mediumSpacing),
          
          // Edit button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(
                Icons.edit,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                'Chỉnh sửa thông tin',
                style: TextStyle(
                  fontSize: screen.ScreenService.smallText,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                padding: EdgeInsets.symmetric(
                  vertical: screen.ScreenService.smallSpacing,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}