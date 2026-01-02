import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../models/user_model.dart';
import 'profile_avatar.dart';
import 'membership_badge.dart';

class UserInfoHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final String? actualTierName;

  const UserInfoHeader({
    super.key,
    required this.user,
    this.onTap,
    this.actualTierName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(
          avatarUrl: user.avatarUrl,
          membershipLevel: actualTierName ?? user.membershipLevel,
          radius: 30,
        ),
        SizedBox(width: screen.ScreenService.mediumSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user.displayName,
                      style: TextStyle(
                        fontSize: screen.ScreenService.mediumText,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  MembershipBadge(membershipLevel: actualTierName ?? user.membershipLevel),
                ],
              ),
              SizedBox(height: screen.ScreenService.smallSpacing / 2),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: screen.ScreenService.smallText,
                  color: AppColors.textSecondary,
                ),
              ),
              if (user.phone.isNotEmpty) ...[
                SizedBox(height: screen.ScreenService.smallSpacing / 2),
                Text(
                  user.phone,
                  style: TextStyle(
                    fontSize: screen.ScreenService.smallText,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textSecondary,
          ),
      ],
    );
  }
}
