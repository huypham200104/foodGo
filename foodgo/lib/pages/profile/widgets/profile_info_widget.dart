import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../models/user_model.dart';
import '../../../utils/tier_system.dart';
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
    // Calculate actual tier based on points
    final actualTier = TierSystem.getTierByPoints(user.totalEarnedPoints);
    
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
          UserInfoHeader(
            user: user, 
            onTap: onTap,
            actualTierName: actualTier.name,
          ),
          
          SizedBox(height: screen.ScreenService.mediumSpacing),
          
          // Stats row
          UserStatsWidget(
            rewardPoints: user.rewardPoints,
            totalOrders: user.totalOrders,
          ),
          
          SizedBox(height: screen.ScreenService.mediumSpacing),

          // ✨ Membership Progress Section
          _buildMembershipProgress(context, user),
          
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

  Widget _buildMembershipProgress(BuildContext context, UserModel user) {
    // Use TierSystem to calculate tier based on ACTUAL points (not saved membershipLevel)
    int currentPoints = user.totalEarnedPoints;
    final currentTier = TierSystem.getTierByPoints(currentPoints);
    final nextTierConfig = currentTier.nextTier != null 
        ? TierSystem.getTierByName(currentTier.nextTier!) 
        : null;
    
    double progress = TierSystem.calculateProgress(currentPoints, currentTier.name);
    String nextTier = currentTier.nextTier ?? '';
    int targetPoints = nextTierConfig?.minPoints ?? currentPoints;
    
    bool isMaxTier = currentTier.nextTier == null;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Hạng thành viên: ${currentTier.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isMaxTier)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '$currentPoints / $targetPoints điểm',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.textLight.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          SizedBox(height: 8),
          Text(
            isMaxTier 
                ? 'Bạn đã đạt hạng cao nhất!' 
                : 'Tích thêm ${targetPoints - currentPoints} điểm để lên hạng $nextTier',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
