import 'package:flutter/material.dart';
import '../../../services/screen_service.dart' as screen;

class MembershipBadge extends StatelessWidget {
  final String membershipLevel;
  final bool isSmall;

  const MembershipBadge({
    super.key,
    required this.membershipLevel,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? screen.ScreenService.smallSpacing / 3 : screen.ScreenService.smallSpacing / 2,
        vertical: isSmall ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: _getMembershipColor(membershipLevel),
        borderRadius: BorderRadius.circular(isSmall ? 6 : 8),
      ),
      child: Text(
        membershipLevel,
        style: TextStyle(
          fontSize: isSmall 
              ? screen.ScreenService.smallText - 3
              : screen.ScreenService.smallText - 2,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getMembershipColor(String level) {
    switch (level) {
      case 'Platinum':
        return const Color(0xFF9C9C9C); // Platinum gray
      case 'Gold':
        return const Color(0xFFFFD700); // Gold
      case 'Silver':
        return const Color(0xFFC0C0C0); // Silver
      case 'Bronze':
        return const Color(0xFFCD7F32); // Bronze
      case 'New':
        return const Color(0xFF757575); // Dark gray for New
      default:
        return const Color(0xFFCD7F32);
    }
  }
}
