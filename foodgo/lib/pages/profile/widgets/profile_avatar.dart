import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String avatarUrl;
  final String membershipLevel;
  final double radius;
  final bool showBadge;

  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    required this.membershipLevel,
    this.radius = 30,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: avatarUrl.isEmpty
              ? Icon(
                  Icons.person,
                  size: radius,
                  color: AppColors.primary,
                )
              : null,
        ),
        // Membership badge
        if (showBadge && membershipLevel != 'Bronze')
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: _getMembershipColor(membershipLevel),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(
                Icons.star,
                size: radius * 0.4,
                color: Colors.white,
              ),
            ),
          ),
      ],
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