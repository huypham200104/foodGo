import 'package:flutter/material.dart';
import 'package:foodgo/models/menu_item_model.dart';
import 'package:foodgo/core/theme/app_colors.dart';
import 'package:foodgo/services/screen_service.dart' as screen;
import 'package:foodgo/services/favorite_service.dart';
import 'package:foodgo/widgets/network_image_with_fallback.dart';

class ProductCard extends StatefulWidget {
  final MenuItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool? isFavorite;
  final VoidCallback? onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.item,
    this.onTap,
    this.onAddToCart,
    this.isFavorite,
    this.onFavoriteToggle,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite ?? false;
    if (widget.isFavorite == null) {
      _checkFavoriteStatus();
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await FavoriteService.isFavorite(widget.item.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final success = await FavoriteService.toggleFavorite(widget.item.id);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (success) {
          _isFavorite = !_isFavorite;
        }
      });

      if (success) {
        // Call parent callback if provided
        widget.onFavoriteToggle?.call();

        // Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite
                  ? '❤️ Đã thêm "${widget.item.name}" vào yêu thích'
                  : '💔 Đã xóa "${widget.item.name}" khỏi yêu thích',
            ),
            backgroundColor: _isFavorite ? AppColors.success : AppColors.textSecondary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Debug: Log khi card được tap
        debugPrint('ProductCard tapped: ${widget.item.id} - ${widget.item.name}');
        debugPrint('onTap callback exists: ${widget.onTap != null}');
        
        // Gọi callback nếu có
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          debugPrint('No onTap callback provided for ProductCard');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image với badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(screen.ScreenService.smallSpacing),
                  ),
                  child: NetworkImageWithFallback(
                    imageUrl: widget.item.imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                
                // New badge
                if (widget.item.isRecentlyAdded)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'MỚI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screen.ScreenService.smallText - 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // Bestseller badge
                if (widget.item.isBestseller)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'BÁN CHẠY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screen.ScreenService.smallText - 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // Favorite button (heart icon) - Bottom left
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                              ),
                            )
                          : Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorite ? AppColors.error : Colors.grey[600],
                              size: 18,
                            ),
                    ),
                  ),
                ),
                
                // Add to cart button
                if (widget.onAddToCart != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        debugPrint('Add to cart tapped: ${widget.item.id} - ${widget.item.name}');
                        widget.onAddToCart!();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  screen.ScreenService.smallSpacing,
                  screen.ScreenService.smallSpacing,
                  screen.ScreenService.smallSpacing,
                  screen.ScreenService.smallSpacing / 2, // Reduced bottom padding
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    Text(
                      widget.item.name,
                      style: TextStyle(
                        fontSize: screen.ScreenService.smallText,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    
                    // Description
                    Expanded(
                      child: Text(
                        widget.item.description,
                        style: TextStyle(
                          fontSize: screen.ScreenService.smallText - 2,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 2),
                    
                    // Price
                    Text(
                      widget.item.formattedPrice,
                      style: TextStyle(
                        fontSize: screen.ScreenService.mediumText,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    
                    // Sold count for bestsellers (only on larger screens)
                    if (widget.item.isBestseller && !screen.ScreenService.isSmallScreen)
                      Text(
                        'Đã bán ${widget.item.soldCount}',
                        style: TextStyle(
                          fontSize: screen.ScreenService.smallText - 2,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

