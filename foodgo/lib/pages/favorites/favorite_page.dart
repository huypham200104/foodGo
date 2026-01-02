import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/screen_service.dart' as screen;
import '../../services/favorite_service.dart';
import '../../models/menu_item_model.dart';
import '../../core/routes/app_routes.dart';
import '../home/widgets/product_card.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  bool _isLoading = true;
  List<MenuItemModel> _favoriteItems = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await FavoriteService.getFavoriteItems();
      if (mounted) {
        setState(() {
          _favoriteItems = items;
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

  Future<void> _handleRefresh() async {
    await _loadFavorites();
  }

  void _navigateToProductDetail(String productId) {
    Navigator.pushNamed(
      context,
      AppRoutes.productDetail,
      arguments: productId,
    );
  }

  @override
  Widget build(BuildContext context) {
    screen.ScreenService.init(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
        title: Text(
          'Sản phẩm yêu thích',
          style: TextStyle(
            fontSize: screen.ScreenService.largeText,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_favoriteItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep, color: AppColors.error),
              onPressed: _showClearAllDialog,
              tooltip: 'Xóa tất cả',
            ),
        ],
      ),
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screen.ScreenService.availableHeight,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                SizedBox(height: screen.ScreenService.mediumSpacing),
                Text(
                  'Có lỗi xảy ra',
                  style: TextStyle(
                    fontSize: screen.ScreenService.mediumText,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: screen.ScreenService.smallSpacing),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screen.ScreenService.mediumSpacing,
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      fontSize: screen.ScreenService.smallText,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: screen.ScreenService.mediumSpacing),
                ElevatedButton(
                  onPressed: _loadFavorites,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_favoriteItems.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screen.ScreenService.availableHeight,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: AppColors.textLight,
                ),
                SizedBox(height: screen.ScreenService.mediumSpacing),
                Text(
                  'Chưa có sản phẩm yêu thích',
                  style: TextStyle(
                    fontSize: screen.ScreenService.mediumText,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: screen.ScreenService.smallSpacing),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screen.ScreenService.mediumSpacing,
                  ),
                  child: Text(
                    'Hãy thêm sản phẩm yêu thích của bạn\nbằng cách bấm vào biểu tượng trái tim',
                    style: TextStyle(
                      fontSize: screen.ScreenService.smallText,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: screen.ScreenService.largeSpacing),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Khám phá sản phẩm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: screen.ScreenService.largeSpacing,
                      vertical: screen.ScreenService.mediumSpacing,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Calculate responsive aspect ratio
    final double itemWidth = (screen.ScreenService.width - 
        (screen.ScreenService.mediumSpacing * 3)) / 2;
    final double itemHeight = screen.ScreenService.isSmallScreen 
        ? itemWidth * 1.5 
        : itemWidth * 1.45;
    final double aspectRatio = itemWidth / itemHeight;

    return GridView.builder(
      padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: screen.ScreenService.mediumSpacing,
        mainAxisSpacing: screen.ScreenService.mediumSpacing,
      ),
      itemCount: _favoriteItems.length,
      itemBuilder: (context, index) {
        final item = _favoriteItems[index];
        return ProductCard(
          item: item,
          isFavorite: true,
          onTap: () => _navigateToProductDetail(item.id),
          onFavoriteToggle: () {
            // Remove from list when unfavorited
            setState(() {
              _favoriteItems.removeAt(index);
            });
          },
        );
      },
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Xóa tất cả?'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa tất cả sản phẩm yêu thích?',
          style: TextStyle(
            fontSize: screen.ScreenService.smallText,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await FavoriteService.clearAllFavorites();
              if (success && mounted) {
                setState(() {
                  _favoriteItems.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa tất cả sản phẩm yêu thích'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }
}

