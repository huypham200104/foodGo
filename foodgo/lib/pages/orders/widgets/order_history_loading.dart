import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class OrderHistoryLoading extends StatelessWidget {
  const OrderHistoryLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: screen.ScreenService.mediumSpacing),
          Text(
            'Đang tải đơn hàng...',
            style: TextStyle(
              fontSize: screen.ScreenService.mediumText,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}