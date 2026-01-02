import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodgo/providers/auth_provider.dart';
import 'package:foodgo/core/theme/app_colors.dart';
import 'package:foodgo/core/routes/app_routes.dart';
import 'package:foodgo/services/screen_service.dart';
import 'package:foodgo/providers/cart_provider.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ScreenService.init(context);
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Tính toán height dynamically
        final navHeight = ScreenService.isSmallScreen ? 70.0 : 75.0;
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        
        return Container(
          height: navHeight + bottomPadding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 8,
                offset: const Offset(0, -4),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main nav content
              Container(
                height: navHeight,
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenService.isSmallScreen ? 8 : 12,
                  vertical: ScreenService.isSmallScreen ? 4 : 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context: context,
                      index: 0,
                      icon: Icons.home,
                      label: 'Trang chủ',
                      isSelected: currentIndex == 0,
                      onTap: () {
                        onTap(0);
                        _navigateToHome(context);
                      },
                    ),
                    _buildNavItem(
                      context: context,
                      index: 1,
                      icon: Icons.notifications,
                      label: 'Thông báo',
                      isSelected: currentIndex == 1,
                      onTap: () {
                        onTap(1);
                        _navigateToNotification(context);
                      },
                    ),
                    _buildNavItem(
                      context: context,
                      index: 2,
                      icon: Icons.restaurant_menu,
                      label: 'Đặt món',
                      isSelected: currentIndex == 2,
                      isHighlighted: true,
                      onTap: () {
                        onTap(2);
                        _navigateToMenu(context);
                      },
                    ),
                    _buildNavItem(
                      context: context,
                      index: 3,
                      icon: Icons.shopping_cart,
                      label: 'Giỏ hàng',
                      isSelected: currentIndex == 3,
                      onTap: () {
                        onTap(3);
                        _navigateToCart(context, authProvider);
                      },
                    ),
                    _buildNavItem(
                      context: context,
                      index: 4,
                      icon: Icons.person,
                      label: 'Tài khoản',
                      isSelected: currentIndex == 4,
                      onTap: () {
                        onTap(4);
                        _navigateToProfile(context, authProvider);
                      },
                    ),
                  ],
                ),
              ),
              
              // Bottom padding placeholder
              if (bottomPadding > 0)
                SizedBox(height: bottomPadding),
            ],
          ),
        );
      },
    );
  }

  // ================== NAVIGATION METHODS ==================

  void _navigateToHome(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != AppRoutes.home) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false, // Remove tất cả routes khác
      );
    }
  }

  void _navigateToNotification(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != AppRoutes.notification) {
      Navigator.of(context).pushNamed(AppRoutes.notification);
    }
  }

  void _navigateToMenu(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != AppRoutes.menu) {
      Navigator.of(context).pushNamed(AppRoutes.menu);
    }
  }

  void _navigateToCart(BuildContext context, AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      Navigator.of(context).pushNamed(AppRoutes.login);
      return;
    }
    
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != AppRoutes.cart) {
      Navigator.of(context).pushNamed(AppRoutes.cart);
    }
  }

  void _navigateToProfile(BuildContext context, AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      Navigator.of(context).pushNamed(AppRoutes.login);
      return;
    }
    
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != AppRoutes.profile) {
      Navigator.of(context).pushNamed(AppRoutes.profile);
    }
  }

  // ================== UI BUILDING METHODS ==================

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    ScreenService.init(context);
    
    // Tính toán sizes để fit trong available space
    final iconContainerSize = ScreenService.isSmallScreen ? 28.0 : 32.0;
    final iconSize = ScreenService.isSmallScreen ? 18.0 : 20.0;
    final fontSize = ScreenService.isSmallScreen ? 8.0 : 9.0;
    final spacing = ScreenService.isSmallScreen ? 2.0 : 3.0;
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  gradient: isHighlighted
                      ? AppColors.primaryGradient
                      : isSelected
                          ? LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.15),
                                AppColors.primaryLight.withValues(alpha: 0.15),
                              ],
                            )
                          : null,
                  shape: BoxShape.circle,
                  boxShadow: isHighlighted ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ] : null,
                ),
                child: _buildIconWithBadge(icon, index, isSelected, isHighlighted, iconSize),
              ),
              
              // Spacing
              SizedBox(height: spacing),
              
              // Label
              SizedBox(
                height: ScreenService.isSmallScreen ? 12 : 14,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontSize: fontSize,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithBadge(IconData icon, int index, bool isSelected, bool isHighlighted, double iconSize) {
    if (index == 3) { // Shopping cart with badge
      return Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final count = cartProvider.items.length;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  icon,
                  color: isHighlighted 
                      ? Colors.white 
                      : (isSelected ? AppColors.primary : AppColors.textSecondary),
                  size: iconSize,
                ),
              ),
              if (count > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 0.5),
                    ),
                    constraints: BoxConstraints(
                      minWidth: ScreenService.isSmallScreen ? 12 : 14, 
                      minHeight: ScreenService.isSmallScreen ? 12 : 14,
                    ),
                    child: Center(
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenService.isSmallScreen ? 7 : 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }
    
    return Center(
      child: Icon(
        icon,
        color: isHighlighted 
            ? Colors.white 
            : (isSelected ? AppColors.primary : AppColors.textSecondary),
        size: iconSize,
      ),
    );
  }
}

