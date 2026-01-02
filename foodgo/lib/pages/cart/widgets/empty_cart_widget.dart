import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';

class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenService.mediumSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined, 
              size: ScreenService.largeSpacing * 3,
              color: Colors.grey[400],
            ),
            SizedBox(height: ScreenService.mediumSpacing),
            Text(
              'Giỏ hàng trống',
              style: TextStyle(
                fontSize: ScreenService.largeText,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: ScreenService.smallSpacing),
            Text(
              'Hãy thêm món để tiếp tục.',
              style: TextStyle(
                fontSize: ScreenService.mediumText,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: ScreenService.mediumSpacing),
            SizedBox(
              width: double.infinity,
              height: ScreenService.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.menu);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
                  ),
                ),
                child: Text(
                  'Xem thực đơn',
                  style: TextStyle(fontSize: ScreenService.mediumText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
