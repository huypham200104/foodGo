import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../services/screen_service.dart' as screen;

class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screen.ScreenService.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screen.ScreenService.largeSpacing),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            
            SizedBox(height: screen.ScreenService.largeSpacing),
            
            Text(
              'Giỏ hàng trống',
              style: TextStyle(
                fontSize: screen.ScreenService.largeText,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            
            SizedBox(height: screen.ScreenService.smallSpacing),
            
            Text(
              'Hãy thêm món ăn vào giỏ hàng\nđể tiếp tục đặt hàng',
              style: TextStyle(
                fontSize: screen.ScreenService.mediumText,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: screen.ScreenService.largeSpacing),
            
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.menu);
              },
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Khám phá món ăn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: screen.ScreenService.largeSpacing,
                  vertical: screen.ScreenService.mediumSpacing,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}