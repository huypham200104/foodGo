import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/cart_item_model.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../utils/format_helper.dart';

class OrderSummarySection extends StatelessWidget {
  final List<CartItemModel> cartItems;
  final double discountAmount;
  final double tierDiscountAmount;
  final double deliveryFee;

  const OrderSummarySection({
    super.key,
    required this.cartItems,
    this.discountAmount = 0.0,
    this.tierDiscountAmount = 0.0,
    this.deliveryFee = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateSubtotal();
    final total = subtotal + deliveryFee - discountAmount - tierDiscountAmount;

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
          
          // Subtotal
          _buildSummaryRow('Tạm tính', subtotal),
          
          // Delivery Fee
          if (deliveryFee > 0)
            _buildSummaryRow('Phí giao hàng', deliveryFee),
            
          // Tier Discount
          if (tierDiscountAmount > 0)
            _buildSummaryRow(
              'Giảm giá hạng thành viên', 
              -tierDiscountAmount, 
              isDiscount: true
            ),

          // Voucher Discount
          if (discountAmount > 0)
            _buildSummaryRow(
              'Voucher giảm giá', 
              -discountAmount, 
              isDiscount: true
            ),

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
                FormatHelper.formatCurrency(total > 0 ? total : 0),
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

  Widget _buildSummaryRow(String label, double value, {bool isDiscount = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: screen.ScreenService.smallSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: screen.ScreenService.smallText,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            FormatHelper.formatCurrency(value),
            style: TextStyle(
              fontSize: screen.ScreenService.smallText,
              color: isDiscount ? AppColors.success : AppColors.textPrimary,
              fontWeight: isDiscount ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal() {
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}
