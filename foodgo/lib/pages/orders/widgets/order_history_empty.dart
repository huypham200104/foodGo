import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class OrderHistoryEmpty extends StatelessWidget {
  final String message;

  const OrderHistoryEmpty({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textLight,
          ),
          SizedBox(height: screen.ScreenService.mediumSpacing),
          Text(
            'Không có đơn hàng nào',
            style: TextStyle(
              fontSize: screen.ScreenService.mediumText,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: screen.ScreenService.smallSpacing),
          Text(
            message,
            style: TextStyle(
              fontSize: screen.ScreenService.smallText,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}