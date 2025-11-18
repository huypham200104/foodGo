import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/menu_item_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';

class FoodCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool showBadge;
  final String? badgeText;
  final Color? badgeColor;

  const FoodCard({
    super.key,
    required this.item,
    this.onTap,
    this.onAddToCart,
    this.showBadge = false,
    this.badgeText,
    this.badgeColor,
  });

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
            debugPrint('Food card tapped: ${item.id} - ${item.name}');
            debugPrint('onTap callback exists: ${onTap != null}');
            
            // Gọi onTap callback nếu có
            if (onTap != null) {
              onTap!();
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
                          imageUrl: item.imageUrl ?? '',
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
                    if (showBadge && badgeText != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor ?? AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: (badgeColor ?? AppColors.primary).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            badgeText!,
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
                        onTap: () {
                          debugPrint('Favorite tapped: ${item.id}');
                          // TODO: Implement favorite functionality
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            color: AppColors.textSecondary,
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
                          item.name,
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
                              '${item.price.toStringAsFixed(0)}đ',
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
                              debugPrint('Add to cart tapped: ${item.id} - ${item.name}');
                              debugPrint('onAddToCart callback exists: ${onAddToCart != null}');
                              
                              // Prevent event bubbling to parent InkWell
                              if (onAddToCart != null) {
                                onAddToCart!();
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
                                    color: AppColors.primary.withOpacity(0.3),
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

