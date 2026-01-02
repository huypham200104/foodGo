import 'package:flutter/material.dart';
import 'package:foodgo/core/theme/app_colors.dart';
import 'package:foodgo/services/screen_service.dart';

class LoginTabBar extends StatelessWidget {
  final TabController tabController;

  const LoginTabBar({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: tabController,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: ScreenService.mediumText,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: ScreenService.mediumText,
        ),
        tabs: [
          Tab(
            height: ScreenService.isSmallScreen ? 45 : 50,
            text: 'Email',
          ),
          Tab(
            height: ScreenService.isSmallScreen ? 45 : 50,
            text: 'Số điện thoại',
          ),
        ],
      ),
    );
  }
}
