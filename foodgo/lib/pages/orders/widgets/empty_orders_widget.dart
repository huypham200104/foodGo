import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../widgets/custom_button.dart';

class EmptyOrdersWidget extends StatelessWidget {
  const EmptyOrdersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screen.ScreenService.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(screen.ScreenService.largeSpacing),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            
            SizedBox(height: screen.ScreenService.largeSpacing),
            
            // Title
            Text(
              'Chưa có đơn hàng nào',
              style: TextStyle(
                fontSize: screen.ScreenService.largeText,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            
            SizedBox(height: screen.ScreenService.mediumSpacing),
            
            // Description
            Text(
              'Bạn chưa có đơn hàng nào.\nHãy khám phá và đặt món yêu thích ngay!',
              style: TextStyle(
                fontSize: screen.ScreenService.mediumText,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: screen.ScreenService.largeSpacing * 2),
            
            // Start ordering button
            CustomButton(
              text: 'Bắt đầu đặt hàng',
              type: ButtonType.primary,
              onPressed: () {
                // Navigate back to home
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.restaurant_menu, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

