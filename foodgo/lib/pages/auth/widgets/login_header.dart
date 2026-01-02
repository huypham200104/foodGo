import 'package:flutter/material.dart';
import 'package:foodgo/core/theme/app_colors.dart';
import 'package:foodgo/services/screen_service.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: ScreenService.largeSpacing + 8),
        
        // Logo
        Container(
          padding: EdgeInsets.all(ScreenService.smallSpacing + 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.restaurant_menu,
            size: ScreenService.isSmallScreen ? 50 : 60,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: ScreenService.mediumSpacing),
        
        // Tiêu đề chính
        Text(
          'Chào mừng trở lại!',
          style: TextStyle(
            fontSize: ScreenService.titleText,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        
        // Tiêu đề phụ
        Text(
          'Đăng nhập để tiếp tục sử dụng FoodGo',
          style: TextStyle(
            fontSize: ScreenService.mediumText,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: ScreenService.largeSpacing + 8),
      ],
    );
  }
}

