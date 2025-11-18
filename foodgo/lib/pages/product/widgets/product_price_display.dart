import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';
import '../../../models/menu_item_model.dart';

class ProductPriceDisplay extends StatelessWidget {
  final MenuItemModel product;
  final int quantity;
  final List<Map<String, dynamic>> selectedToppings;

  const ProductPriceDisplay({
    super.key,
    required this.product,
    required this.quantity,
    required this.selectedToppings,
  });

  @override
  Widget build(BuildContext context) {
    final basePrice = product.price * quantity;
    final toppingsPrice = selectedToppings.fold<double>(
      0.0,
      (sum, topping) => sum + (topping['price'] ?? 0.0),
    ) * quantity;
    final totalPrice = basePrice + toppingsPrice;

    return Container(
      width: double.infinity, // 👈 Đảm bảo full width
      margin: EdgeInsets.only(bottom: ScreenService.mediumSpacing),
      padding: EdgeInsets.all(ScreenService.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 👈 Thu nhỏ column
        children: [
          Text(
            'Chi tiết giá',
            style: TextStyle(
              fontSize: ScreenService.mediumText,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ScreenService.smallSpacing),
          
          // Base price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  '${product.name} (x$quantity)',
                  style: TextStyle(
                    fontSize: ScreenService.smallText,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              Expanded(
                flex: 2,
                child: Text(
                  _formatPrice(basePrice),
                  style: TextStyle(
                    fontSize: ScreenService.smallText,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          // Toppings price
          if (selectedToppings.isNotEmpty) ...[
            SizedBox(height: ScreenService.smallSpacing / 2),
            ...selectedToppings.map((topping) => Padding(
              padding: EdgeInsets.only(bottom: ScreenService.smallSpacing / 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${topping['name']} (x$quantity)',
                      style: TextStyle(
                        fontSize: ScreenService.smallText,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  Expanded(
                    flex: 2,
                    child: Text(
                      _formatPrice((topping['price'] ?? 0.0) * quantity),
                      style: TextStyle(
                        fontSize: ScreenService.smallText,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
          ],
          
          Padding(
            padding: EdgeInsets.symmetric(vertical: ScreenService.smallSpacing / 2),
            child: Divider(
              color: AppColors.textLight,
              height: 1,
            ),
          ),

          // Total price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Tổng cộng',
                  style: TextStyle(
                    fontSize: ScreenService.mediumText,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Expanded(
                flex: 2,
                child: Text(
                  _formatPrice(totalPrice),
                  style: TextStyle(
                    fontSize: ScreenService.mediumText,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    // 👈 Format theo 30.000 VND thay vì 30000 VND
    return '${price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    )} VND';
  }
}
