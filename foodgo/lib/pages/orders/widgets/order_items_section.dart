import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../models/cart_item_model.dart';
import '../../../utils/currency_formatter.dart';

class OrderItemsSection extends StatelessWidget {
  final List<CartItemModel> items;

  const OrderItemsSection({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Món đã đặt',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: screen.ScreenService.smallText + 1,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: screen.ScreenService.smallSpacing),
        
        // Items list
        ...items.map((cartItem) => _buildOrderItem(cartItem)).toList(),
      ],
    );
  }

  Widget _buildOrderItem(CartItemModel cartItem) {
    return Container(
      margin: EdgeInsets.only(bottom: screen.ScreenService.smallSpacing),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Main item info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: screen.ScreenService.smallText,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${_formatCurrency(cartItem.item.price)} x ${cartItem.quantity}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: screen.ScreenService.smallText - 1,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatCurrency(cartItem.totalPrice),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: screen.ScreenService.smallText,
                ),
              ),
            ],
          ),
          
          // Toppings
          if (cartItem.selectedToppings.isNotEmpty) ...[
            SizedBox(height: 8),
            ...cartItem.selectedToppings.map((topping) => Padding(
              padding: EdgeInsets.only(left: 16, bottom: 2),
              child: Row(
                children: [
                  Text(
                    '+ ',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: screen.ScreenService.smallText - 2,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      topping['name'] ?? '',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: screen.ScreenService.smallText - 2,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Text(
                    '+${_formatCurrency(topping['price']?.toDouble() ?? 0)}',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: screen.ScreenService.smallText - 2,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
          
          // Note
          if (cartItem.note.isNotEmpty) ...[
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    size: 14,
                    color: AppColors.textLight,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      cartItem.note,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: screen.ScreenService.smallText - 2,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}đ';
  }
}