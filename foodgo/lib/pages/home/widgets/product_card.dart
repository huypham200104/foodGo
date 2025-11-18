import 'package:flutter/material.dart';
import 'package:foodgo/models/menu_item_model.dart';
import 'package:foodgo/core/theme/app_colors.dart';
import 'package:foodgo/services/screen_service.dart' as screen;
import 'package:foodgo/widgets/network_image_with_fallback.dart';

class ProductCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.item,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Debug: Log khi card được tap
        debugPrint('ProductCard tapped: ${item.id} - ${item.name}');
        debugPrint('onTap callback exists: ${onTap != null}');
        
        // Gọi callback nếu có
        if (onTap != null) {
          onTap!();
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
              color: Colors.black.withOpacity(0.1),
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
                    imageUrl: item.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                
                // New badge
                if (item.isRecentlyAdded)
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
                if (item.isBestseller)
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
                
                // Add to cart button
                if (onAddToCart != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        debugPrint('Add to cart tapped: ${item.id} - ${item.name}');
                        onAddToCart!();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
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
                padding: EdgeInsets.all(screen.ScreenService.smallSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: screen.ScreenService.smallText,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        
                        // Description
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: screen.ScreenService.smallText - 2,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price
                        Text(
                          item.formattedPrice,
                          style: TextStyle(
                            fontSize: screen.ScreenService.mediumText,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        
                        // Sold count for bestsellers
                        if (item.isBestseller)
                          Text(
                            'Đã bán ${item.soldCount}',
                            style: TextStyle(
                              fontSize: screen.ScreenService.smallText - 2,
                              color: Colors.grey[500],
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
    );
  }
}