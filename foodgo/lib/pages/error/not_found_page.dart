import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../services/screen_service.dart' as screen;

class NotFoundPage extends StatelessWidget {
  final String message;

  const NotFoundPage({
    super.key, // 👈 Sử dụng super.key thay vì Key?
    this.message = 'Trang không tồn tại',
  });

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenService
    screen.ScreenService.init(context);

    return Scaffold(
      backgroundColor: AppColors.background, // 👈 Sử dụng AppColors
      appBar: AppBar(
        title: Text(
          'Không tìm thấy trang',
          style: TextStyle(
            fontSize: screen.ScreenService.largeText,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(screen.ScreenService.largeSpacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon with gradient background
              Container(
                width: screen.ScreenService.isSmallScreen ? 100 : 120,
                height: screen.ScreenService.isSmallScreen ? 100 : 120,
                decoration: BoxDecoration(
                  gradient: AppColors.errorGradient, // 👈 Sử dụng gradient
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.error_outline,
                  size: screen.ScreenService.isSmallScreen ? 50 : 60,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: screen.ScreenService.largeSpacing),
              
              // 404 Text
              Text(
                '404',
                style: TextStyle(
                  fontSize: screen.ScreenService.isSmallScreen ? 48 : 64,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              
              SizedBox(height: screen.ScreenService.smallSpacing),
              
              // Error Message
              Text(
                message,
                style: TextStyle(
                  fontSize: screen.ScreenService.largeText,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: screen.ScreenService.smallSpacing),
              
              // Subtitle
              Text(
                'Trang bạn tìm kiếm không tồn tại hoặc đã bị di chuyển',
                style: TextStyle(
                  fontSize: screen.ScreenService.smallText,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: screen.ScreenService.largeSpacing * 2),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, AppRoutes.home); // 👈 Fallback to home
                        }
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Quay lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        side: BorderSide(color: AppColors.border),
                        minimumSize: Size(0, screen.ScreenService.buttonHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: screen.ScreenService.mediumSpacing),
                  
                  // Home Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _goToHome(context), // 👈 Sửa navigation
                      icon: const Icon(Icons.home),
                      label: const Text('Về trang chủ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(0, screen.ScreenService.buttonHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: screen.ScreenService.mediumSpacing),
              
              // Additional Info Card
              Container(
                padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: screen.ScreenService.smallSpacing),
                    Expanded(
                      child: Text(
                        'Nếu bạn nghĩ đây là lỗi, vui lòng liên hệ với chúng tôi',
                        style: TextStyle(
                          fontSize: screen.ScreenService.smallText,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 👈 Helper method để navigate về home
  void _goToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false, // Clear all previous routes
    );
  }
}

