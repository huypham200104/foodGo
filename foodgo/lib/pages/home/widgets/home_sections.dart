import 'package:flutter/material.dart';
import '../../../models/menu_item_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';
import '../../../core/routes/app_routes.dart';
import 'section_header.dart';
import 'horizontal_card_list.dart';
import 'food_card.dart';

class HomeSections extends StatelessWidget {
  final List<MenuItemModel> newProducts;
  final List<MenuItemModel> bestsellerProducts;
  final Function(String) onNavigateToProductDetail;
  final Function(MenuItemModel) onAddToCart;
  final VoidCallback onRefreshData;

  const HomeSections({
    super.key,
    required this.newProducts,
    required this.bestsellerProducts,
    required this.onNavigateToProductDetail,
    required this.onAddToCart,
    required this.onRefreshData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sản phẩm mới Section
        if (newProducts.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(top: ScreenService.sectionSpacing),
            child: SectionHeader(
              title: 'Sản phẩm mới',
              subtitle: 'Những món ăn mới nhất và hấp dẫn',
              leadingIcon: Container(
                padding: EdgeInsets.all(ScreenService.smallSpacing / 2),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.fiber_new,
                  size: ScreenService.isSmallScreen ? 16 : 20,
                  color: Colors.white,
                ),
              ),
              onSeeAllTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.menu,
                  arguments: {'filter': 'new'},
                );
              },
            ),
          ),
          Container(
            height: ScreenService.isSmallScreen ? 200 : 220,
            padding: EdgeInsets.only(bottom: ScreenService.smallSpacing),
            child: HorizontalCardList<MenuItemModel>(
              items: newProducts,
              height: ScreenService.isSmallScreen ? 200 : 220,
              emptyMessage: 'Chưa có sản phẩm mới',
              cardBuilder: (item) => FoodCard(
                item: item,
                onTap: () {
                  debugPrint('FoodCard onTap called for: ${item.id}');
                  onNavigateToProductDetail(item.id);
                },
                onAddToCart: () {
                  debugPrint('FoodCard onAddToCart called for: ${item.id}');
                  onAddToCart(item);
                },
                showBadge: true,
                badgeText: 'NEW',
                badgeColor: AppColors.success,
              ),
            ),
          ),
        ],

        // Sản phẩm bán chạy Section
        if (bestsellerProducts.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(top: ScreenService.sectionSpacing),
            child: SectionHeader(
              title: 'Sản phẩm bán chạy',
              subtitle: 'Được khách hàng yêu thích nhất',
              leadingIcon: Container(
                padding: EdgeInsets.all(ScreenService.smallSpacing / 2),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_fire_department,
                  size: ScreenService.isSmallScreen ? 16 : 20,
                  color: Colors.white,
                ),
              ),
              onSeeAllTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.menu,
                  arguments: {'filter': 'bestseller'},
                );
              },
            ),
          ),
          Container(
            height: ScreenService.isSmallScreen ? 200 : 220,
            padding: EdgeInsets.only(bottom: ScreenService.smallSpacing),
            child: HorizontalCardList<MenuItemModel>(
              items: bestsellerProducts,
              height: ScreenService.isSmallScreen ? 200 : 220,
              emptyMessage: 'Chưa có sản phẩm bán chạy',
              cardBuilder: (item) => FoodCard(
                item: item,
                onTap: () => onNavigateToProductDetail(item.id),
                onAddToCart: () => onAddToCart(item),
                showBadge: true,
                badgeText: 'HOT',
                badgeColor: AppColors.warning,
              ),
            ),
          ),
        ],

        // Empty state
        if (newProducts.isEmpty && bestsellerProducts.isEmpty)
          _buildEmptyState(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.all(ScreenService.mediumSpacing),
      padding: EdgeInsets.all(ScreenService.largeSpacing),
      constraints: BoxConstraints(
        minHeight: ScreenService.availableHeight * 0.3,
      ),
      decoration: AppColors.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ScreenService.isSmallScreen ? 60 : 80,
            height: ScreenService.isSmallScreen ? 60 : 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu,
              size: ScreenService.isSmallScreen ? 30 : 40,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: ScreenService.mediumSpacing),
          Text(
            'Chưa có sản phẩm',
            style: TextStyle(
              fontSize: ScreenService.largeText,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ScreenService.smallSpacing),
          Text(
            'Hãy thử lại sau để xem những món ăn mới nhất',
            style: TextStyle(
              fontSize: ScreenService.smallText,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenService.mediumSpacing),
          ElevatedButton.icon(
            onPressed: onRefreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Tải lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: Size(0, ScreenService.buttonHeight),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenService.mediumSpacing,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
