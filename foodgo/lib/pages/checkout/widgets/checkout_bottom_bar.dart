import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../models/address_model.dart';

class CheckoutBottomBar extends StatelessWidget {
  final double totalPrice;
  final double deliveryFee;  // Giữ lại nhưng sẽ pass 0
  final bool isProcessing;
  final AddressModel? selectedAddress;
  final VoidCallback onPlaceOrder;

  const CheckoutBottomBar({
    super.key,
    required this.totalPrice,
    this.deliveryFee = 0,  // 👈 Default to 0
    required this.isProcessing,
    required this.selectedAddress,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
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
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price Summary - 👈 Không hiển thị delivery fee
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng:',
                  style: TextStyle(
                    fontSize: screen.ScreenService.largeText,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${totalPrice.toStringAsFixed(0)}đ', // 👈 Chỉ hiển thị total price
                  style: TextStyle(
                    fontSize: screen.ScreenService.largeText,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: screen.ScreenService.mediumSpacing),
            
            // Place Order Button
            SizedBox(
              width: double.infinity,
              height: screen.ScreenService.buttonHeight,
              child: ElevatedButton(
                onPressed: selectedAddress != null && !isProcessing 
                    ? onPlaceOrder 
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.textLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
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