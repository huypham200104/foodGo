import 'package:flutter/material.dart';
import '../../../models/menu_item_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';
import 'home_header.dart';
import 'home_sections.dart';

class HomeContent extends StatelessWidget {
  final List<MenuItemModel> newProducts;
  final List<MenuItemModel> bestsellerProducts;
  final List<String> bannerImageUrls;
  final Function(String) onNavigateToProductDetail;
  final Function(MenuItemModel) onAddToCart;
  final Future<void> Function() onRefreshData;
  final ScrollController scrollController;

  const HomeContent({
    super.key,
    required this.newProducts,
    required this.bestsellerProducts,
    required this.bannerImageUrls,
    required this.onNavigateToProductDetail,
    required this.onAddToCart,
    required this.onRefreshData,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefreshData,
      color: AppColors.primary,
      child: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: HomeHeader(bannerImageUrls: bannerImageUrls),
          ),

          // Sections
          SliverToBoxAdapter(
            child: HomeSections(
              newProducts: newProducts,
              bestsellerProducts: bestsellerProducts,
              onNavigateToProductDetail: onNavigateToProductDetail,
              onAddToCart: onAddToCart,
              onRefreshData: onRefreshData,
            ),
          ),

          // Bottom spacing - Sửa lỗi overflow
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 
                      kBottomNavigationBarHeight + 
                      80 + // Floating button height
                      ScreenService.mediumSpacing,
            ),
          ),
        ],
      ),
    );
  }
}
