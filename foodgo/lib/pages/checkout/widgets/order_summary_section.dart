import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/cart_item_model.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../utils/format_helper.dart';

class OrderSummarySection extends StatelessWidget {
  final List<CartItemModel> cartItems;

  const OrderSummarySection({
    super.key,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tóm tắt đơn hàng',
            style: TextStyle(
              fontSize: screen.ScreenService.mediumText,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: screen.ScreenService.mediumSpacing),
          
          ...cartItems.map((item) => Padding(
            padding: EdgeInsets.only(bottom: screen.ScreenService.smallSpacing),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.quantity}x ${item.item.name}',
                    style: TextStyle(
                      fontSize: screen.ScreenService.smallText,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  FormatHelper.formatCurrency(item.totalPrice),
                  style: TextStyle(
                    fontSize: screen.ScreenService.smallText,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )).toList(),
          
          Divider(color: AppColors.textLight),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng:',
                style: TextStyle(
                  fontSize: screen.ScreenService.mediumText,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                FormatHelper.formatCurrency(_calculateTotal()),
                style: TextStyle(
                  fontSize: screen.ScreenService.mediumText,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}