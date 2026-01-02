import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../models/address_model.dart';
import '../../../utils/format_helper.dart';

class CheckoutBottomBar extends StatelessWidget {
  final double totalPrice;
  final double deliveryFee;
  final bool isProcessing;
  final AddressModel? selectedAddress;
  final VoidCallback onPlaceOrder;

  const CheckoutBottomBar({
    super.key,
    required this.totalPrice,
    this.deliveryFee = 0,
    required this.isProcessing,
    required this.selectedAddress,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalPrice + deliveryFee;

    return Container(
      padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(screen.ScreenService.mediumSpacing),
          topRight: Radius.circular(screen.ScreenService.mediumSpacing),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tạm tính:',
                  style: TextStyle(
                    fontSize: screen.ScreenService.smallText,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  FormatHelper.formatCurrency(totalPrice),
                  style: TextStyle(
                    fontSize: screen.ScreenService.smallText,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (deliveryFee > 0) ...[
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Phí giao hàng:',
                    style: TextStyle(
                      fontSize: screen.ScreenService.smallText,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    FormatHelper.formatCurrency(deliveryFee),
                    style: TextStyle(
                      fontSize: screen.ScreenService.smallText,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
            Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng thanh toán',
                  style: TextStyle(
                    fontSize: screen.ScreenService.mediumText,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  FormatHelper.formatCurrency(total),
                  style: TextStyle(
                    fontSize: screen.ScreenService.largeText,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !isProcessing ? onPlaceOrder : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isProcessing
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Đặt hàng',
                        style: TextStyle(
                          fontSize: screen.ScreenService.mediumText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
