import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/voucher_model.dart';
import '../../models/menu_item_model.dart';
import '../../models/restaurant_model.dart';
import '../../services/menu_service.dart';
import '../../services/screen_service.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart'; // 👈 Chỉ cần import này

// Import widgets
import 'widgets/top_bar.dart';
import 'widgets/search_field.dart';
import 'widgets/top_search_chips.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/category_icons.dart';
import 'widgets/section_header.dart';
import 'widgets/horizontal_card_list.dart';
import 'widgets/food_card.dart';
import 'widgets/product_card.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/floating_chat_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  // Data
  List<MenuItemModel> _newProducts = [];
  List<MenuItemModel> _bestsellerProducts = [];
  List<RestaurantModel> _restaurants = [];
  List<String> _bannerImageUrls = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScreenService.init(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        MenuService.getNewProducts(),
        MenuService.getBestsellerProducts(),
        _loadRestaurants(),
        _loadBannerImages(),
      ]);

      if (mounted) {
        setState(() {
          _newProducts = results[0] as List<MenuItemModel>;
          _bestsellerProducts = results[1] as List<MenuItemModel>;
          _restaurants = results[2] as List<RestaurantModel>;
          _bannerImageUrls = results[3] as List<String>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<List<RestaurantModel>> _loadRestaurants() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return RestaurantModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error loading restaurants: $e');
      return [];
    }
  }

  Future<List<String>> _loadBannerImages() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('vouchers')
          .where('isActive', isEqualTo: true)
          .limit(5)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return data['imageUrl']?.toString() ?? '';
      }).where((url) => url.isNotEmpty).toList();
    } catch (e) {
      print('Error loading banner images: $e');
      return [];
    }
  }

  Future<void> _refreshData() async {
    MenuService.clearCache();
    await _loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    ScreenService.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : _error != null
                    ? _buildErrorState()
                    : _buildHomeContent(),
          ),
          
          // Floating Chat Button
          FloatingChatButton(
            onPressed: () {
              debugPrint('Chat button pressed');
              // TODO: Navigate to chat screen when implemented
            },
            showOnlineIndicator: true,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Top Bar
          SliverToBoxAdapter(
            child: TopBar(
              onNotificationTap: () =>
                  Navigator.pushNamed(context, AppRoutes.notification),
              onProfileTap: () =>
                  Navigator.pushNamed(context, AppRoutes.profile),
              onToggleTheme: () {},
            ),
          ),

          // Search Field
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenService.mediumSpacing,
                vertical: ScreenService.smallSpacing,
              ),
              child: SearchField(
                onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                hintText: 'Tìm kiếm món ăn yêu thích...',
              ),
            ),
          ),

          // Top Search Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: ScreenService.smallSpacing),
              child: TopSearchChips(
                onChipTap: (chipText) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.search,
                    arguments: {'query': chipText},
                  );
                },
              ),
            ),
          ),

          // Banner Carousel
          SliverToBoxAdapter(
            child: Container(
              height: ScreenService.isSmallScreen ? 160 : 200,
              margin: EdgeInsets.symmetric(
                horizontal: ScreenService.mediumSpacing,
                vertical: ScreenService.smallSpacing,
              ),
              child: BannerCarousel(
                imageUrls: _bannerImageUrls,
                onBannerTap: (index) {
                  print('Banner $index tapped');
                },
              ),
            ),
          ),

          // Sản phẩm mới Section - 👈 Sử dụng AppColors thay vì AppGradients
          if (_newProducts.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: ScreenService.sectionSpacing),
                child: SectionHeader(
                  title: 'Sản phẩm mới',
                  subtitle: 'Những món ăn mới nhất và hấp dẫn',
                  leadingIcon: Container(
                    padding: EdgeInsets.all(ScreenService.smallSpacing / 2),
                    decoration: BoxDecoration(
                      gradient: AppColors.successGradient, // 👈 Từ AppColors
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.3),
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
            ),
            SliverToBoxAdapter(
              child: Container(
                height: ScreenService.isSmallScreen ? 200 : 220,
                padding: EdgeInsets.only(bottom: ScreenService.smallSpacing),
                child: HorizontalCardList<MenuItemModel>(
                  items: _newProducts,
                  height: ScreenService.isSmallScreen ? 200 : 220,
                  emptyMessage: 'Chưa có sản phẩm mới',
                  cardBuilder: (item) => FoodCard(
                    item: item,
                    onTap: () => _navigateToProductDetail(item.id),
                    onAddToCart: () => _addToCart(item),
                    showBadge: true,
                    badgeText: 'NEW',
                    badgeColor: AppColors.success,
                  ),
                ),
              ),
            ),
          ],

          // Sản phẩm bán chạy Section - 👈 Sử dụng AppColors
          if (_bestsellerProducts.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: ScreenService.sectionSpacing),
                child: SectionHeader(
                  title: 'Sản phẩm bán chạy',
                  subtitle: 'Được khách hàng yêu thích nhất',
                  leadingIcon: Container(
                    padding: EdgeInsets.all(ScreenService.smallSpacing / 2),
                    decoration: BoxDecoration(
                      gradient: AppColors.warningGradient, // 👈 Từ AppColors
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warning.withOpacity(0.3),
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
            ),
            SliverToBoxAdapter(
              child: Container(
                height: ScreenService.isSmallScreen ? 200 : 220,
                padding: EdgeInsets.only(bottom: ScreenService.smallSpacing),
                child: HorizontalCardList<MenuItemModel>(
                  items: _bestsellerProducts,
                  height: ScreenService.isSmallScreen ? 200 : 220,
                  emptyMessage: 'Chưa có sản phẩm bán chạy',
                  cardBuilder: (item) => FoodCard(
                    item: item,
                    onTap: () => _navigateToProductDetail(item.id),
                    onAddToCart: () => _addToCart(item),
                    showBadge: true,
                    badgeText: 'HOT',
                    badgeColor: AppColors.warning,
                  ),
                ),
              ),
            ),
          ],

          // Empty state
          if (_newProducts.isEmpty && _bestsellerProducts.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(ScreenService.mediumSpacing),
                padding: EdgeInsets.all(ScreenService.largeSpacing),
                constraints: BoxConstraints(
                  minHeight: ScreenService.availableHeight * 0.3,
                ),
                decoration: AppColors.cardDecoration, // 👈 Từ AppColors
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
                      onPressed: _refreshData,
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
              ),
            ),

          // Bottom spacing
          SliverToBoxAdapter(
            child: SizedBox(
              height: (ScreenService.isSmallScreen ? 85 : 90) +
                      80 +
                      ScreenService.mediumSpacing,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: ScreenService.availableHeight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: ScreenService.mediumSpacing),
            Text(
              'Đang tải...',
              style: TextStyle(
                fontSize: ScreenService.mediumText,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: ScreenService.availableHeight,
      padding: EdgeInsets.all(ScreenService.mediumSpacing),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline, 
              size: ScreenService.isSmallScreen ? 48 : 64, 
              color: AppColors.error
            ),
            SizedBox(height: ScreenService.mediumSpacing),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: ScreenService.largeText,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: ScreenService.smallSpacing),
            Text(
              _error ?? 'Không thể tải dữ liệu',
              style: TextStyle(
                fontSize: ScreenService.smallText,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ScreenService.mediumSpacing),
            ElevatedButton.icon(
              onPressed: _loadHomeData,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(0, ScreenService.buttonHeight),
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenService.mediumSpacing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    debugPrint('Bottom nav tapped: $index');
  }

  void _navigateToProductDetail(String productId) {
    Navigator.pushNamed(
      context,
      AppRoutes.productDetail,
      arguments: productId,
    );
  }

  void _addToCart(MenuItemModel item) {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      cartProvider.addItem(item, 1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${item.name} vào giỏ hàng'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Xem giỏ hàng',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi thêm vào giỏ hàng: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}