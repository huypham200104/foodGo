import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/menu_item_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';
import '../../../services/favorite_service.dart';
import '../../../utils/format_helper.dart';

class FoodCard extends StatefulWidget {
  final MenuItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool showBadge;
  final String? badgeText;
  final Color? badgeColor;
  final bool? isFavorite;
  final VoidCallback? onFavoriteToggle;

  const FoodCard({
    super.key,
    required this.item,
    this.onTap,
    this.onAddToCart,
    this.showBadge = false,
    this.badgeText,
    this.badgeColor,
    this.isFavorite,
    this.onFavoriteToggle,
  });

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
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
    ScreenService.init(context);
    
    return Container(
      width: ScreenService.isSmallScreen ? 160 : 180,
      margin: EdgeInsets.only(right: ScreenService.smallSpacing),
      child: Card(
        elevation: 4,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            // Debug: In ra thông tin item để kiểm tra
            debugPrint('Food card tapped: ${widget.item.id} - ${widget.item.name}');
            debugPrint('onTap callback exists: ${widget.onTap != null}');
            
            // Gọi onTap callback nếu có
            if (widget.onTap != null) {
              widget.onTap!();
            } else {
              debugPrint('No onTap callback provided');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image với badge
              Flexible(
                flex: 7,
                child: Stack(
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: widget.item.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.surfaceVariant,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surfaceVariant,
                            child: Center(
                              child: Icon(
                                Icons.restaurant,
                                color: AppColors.textSecondary,
                                size: ScreenService.isSmallScreen ? 30 : 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Badge (NEW hoặc HOT)
                    if (widget.showBadge && widget.badgeText != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: widget.badgeColor ?? AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: (widget.badgeColor ?? AppColors.primary).withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.badgeText!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenService.isSmallScreen ? 8 : 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    
                    // Favorite Button
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: _toggleFavorite,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                                  ),
                                )
                              : Icon(
                                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: _isFavorite ? AppColors.error : AppColors.textSecondary,
                                  size: 16,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Product Info
              Flexible(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.all(ScreenService.smallSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product Name
                      Flexible(
                        child: Text(
                          widget.item.name,
                          style: TextStyle(
                            fontSize: ScreenService.isSmallScreen ? 11 : 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      SizedBox(height: ScreenService.smallSpacing / 2),
                      
                      // Price và Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Price
                          Flexible(
                            child: Text(
                              FormatHelper.formatCurrency(widget.item.price),
                              style: TextStyle(
                                fontSize: ScreenService.isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          SizedBox(width: 4),
                          
                          // Add Button với stopPropagation
                          GestureDetector(
                            onTap: () {
                              debugPrint('Add to cart tapped: ${widget.item.id} - ${widget.item.name}');
                              debugPrint('onAddToCart callback exists: ${widget.onAddToCart != null}');
                              
                              // Prevent event bubbling to parent InkWell
                              if (widget.onAddToCart != null) {
                                widget.onAddToCart!();
                              } else {
                                debugPrint('No onAddToCart callback provided');
                              }
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
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
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



