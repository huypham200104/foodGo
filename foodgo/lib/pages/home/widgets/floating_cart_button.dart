import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../services/screen_service.dart';

class FloatingCartButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool showBadge;
  final EdgeInsetsGeometry? margin;

  const FloatingCartButton({
    super.key,
    this.onPressed,
    this.showBadge = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    ScreenService.init(context);
    
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItemCount = cartProvider.items.length;

        return Container(
          margin: margin ?? EdgeInsets.only(
            bottom: ScreenService.isSmallScreen ? 85 : 90,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main FAB
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: onPressed ?? () => _navigateToCart(context),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  heroTag: "cart_button", // Unique hero tag
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: ScreenService.isSmallScreen ? 22 : 26,
                  ),
                ),
              ),

              // Badge với số lượng sản phẩm
              if (showBadge && cartItemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: _buildBadge(cartItemCount),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: EdgeInsets.all(ScreenService.isSmallScreen ? 4 : 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warning, AppColors.error],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: BoxConstraints(
        minWidth: ScreenService.isSmallScreen ? 20 : 24,
        minHeight: ScreenService.isSmallScreen ? 20 : 24,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: ScreenService.isSmallScreen ? 9 : 11,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _navigateToCart(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.cart);
  }
}