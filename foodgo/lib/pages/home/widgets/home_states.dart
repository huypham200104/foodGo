import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';

class HomeLoadingState extends StatelessWidget {
  const HomeLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenService.availableHeight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: ScreenService.mediumSpacing),
            Text(
              'Đang tải...',
              style: TextStyle(
                fontSize: ScreenService.mediumText,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeErrorState extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  const HomeErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenService.availableHeight,
      child: Padding(
        padding: EdgeInsets.all(ScreenService.mediumSpacing),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: ScreenService.isSmallScreen ? 48 : 64,
                color: AppColors.error,
              ),
              SizedBox(height: ScreenService.mediumSpacing),
              Text(
                'Có lỗi xảy ra',
                style: TextStyle(
                  fontSize: ScreenService.largeText,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: ScreenService.smallSpacing),
              Text(
                error ?? 'Không thể tải dữ liệu',
                style: TextStyle(
                  fontSize: ScreenService.smallText,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ScreenService.mediumSpacing),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(0, ScreenService.buttonHeight),
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenService.mediumSpacing,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
