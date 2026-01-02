import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class OrderHistoryError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const OrderHistoryError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screen.ScreenService.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: screen.ScreenService.mediumSpacing),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: screen.ScreenService.largeText,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: screen.ScreenService.smallSpacing),
            Text(
              message,
              style: TextStyle(
                fontSize: screen.ScreenService.mediumText,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screen.ScreenService.largeSpacing),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: screen.ScreenService.largeSpacing,
                  vertical: screen.ScreenService.mediumSpacing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
