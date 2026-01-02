import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class UserStatColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const UserStatColumn({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        SizedBox(height: screen.ScreenService.smallSpacing / 2),
        Text(
          value,
          style: TextStyle(
            fontSize: screen.ScreenService.mediumText,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: screen.ScreenService.smallText - 2,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
