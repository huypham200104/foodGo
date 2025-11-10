import 'package:flutter/material.dart';
import '../../../models/menu_item_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';
import '../../../widgets/network_image_with_fallback.dart';
import '../../../core/utils/currency.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel menuItem;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const MenuItemCard({
    Key? key,
    required this.menuItem,
    required this.onTap,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: ScreenService.smallSpacing),
      elevation: 2,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
        child: Padding(
          padding: EdgeInsets.all(ScreenService.smallSpacing),
          child: Row(
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(ScreenService.smallSpacing / 2),
                child: NetworkImageWithFallback(
                  imageUrl: menuItem.imageUrl,
                  width: ScreenService.buttonHeight + 20,
                  height: ScreenService.buttonHeight + 20,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: ScreenService.smallSpacing),
              
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menuItem.name,
                      style: TextStyle(
                        fontSize: ScreenService.mediumText,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ScreenService.smallSpacing / 2),
                    
                    if (menuItem.description.isNotEmpty) ...[
                      Text(
                        menuItem.description,
                        style: TextStyle(
                          fontSize: ScreenService.smallText,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: ScreenService.smallSpacing / 2),
                    ],
                    
                    Wrap(
                      spacing: ScreenService.smallSpacing / 2,
                      runSpacing: ScreenService.smallSpacing / 4,
                      children: [
                        // Category badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenService.smallSpacing / 2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            menuItem.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: ScreenService.smallText - 2,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        // Sold count or availability
                        if (menuItem.soldCount > 0)
                          Text(
                            '• ${menuItem.soldCount} đã bán',
                            style: TextStyle(
                              fontSize: ScreenService.smallText,
                              color: AppColors.textLight,
                            ),
                          )
                        else if (menuItem.isNew)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenService.smallSpacing / 2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'MỚI',
                              style: TextStyle(
                                fontSize: ScreenService.smallText - 2,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Price and add button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatVnd(menuItem.price),
                    style: TextStyle(
                      fontSize: ScreenService.mediumText,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: ScreenService.smallSpacing),
                  
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onAddToCart,
                        borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenService.smallSpacing,
                            vertical: ScreenService.smallSpacing / 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Thêm',
                                style: TextStyle(
                                  fontSize: ScreenService.smallText,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  
}


