import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/cart_provider.dart';
import '../../models/menu_item_model.dart';
import '../../models/restaurant_model.dart';
import '../../services/menu_service.dart';
import '../../services/screen_service.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

// Import widgets
import 'widgets/home_content.dart';
import 'widgets/home_states.dart';
import 'widgets/custom_bottom_nav.dart';
import '../../widgets/chat_bubble.dart';

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
                ? const HomeLoadingState()
                : _error != null
                    ? HomeErrorState(
                        error: _error,
                        onRetry: _loadHomeData,
                      )
                    : HomeContent(
                        newProducts: _newProducts,
                        bestsellerProducts: _bestsellerProducts,
                        bannerImageUrls: _bannerImageUrls,
                        onNavigateToProductDetail: _navigateToProductDetail,
                        onAddToCart: _addToCart,
                        onRefreshData: _refreshData,
                        scrollController: _scrollController,
                      ),
          ),

          // Floating Chat Bubble
          Positioned(
            bottom: 20,
            right: 20,
            child: ChatBubble(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    debugPrint('Bottom nav tapped: $index');
  }

  void _navigateToProductDetail(String productId) {
    debugPrint('Navigating to product detail with ID: $productId'); // 👈 Thêm debug log
    Navigator.pushNamed(
      context,
      AppRoutes.productDetail,
      arguments: productId,
    );
  }

  void _addToCart(MenuItemModel item) {
    try {
      // Check if item has toppings - navigate to detail page instead
      final effectiveToppingOptions = item.toppingOptions ?? item.toppings ?? [];
      if (effectiveToppingOptions.isNotEmpty) {
        debugPrint('Item has ${effectiveToppingOptions.length} topping options, navigating to detail page');
        _navigateToProductDetail(item.id);
        return;
      }

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
