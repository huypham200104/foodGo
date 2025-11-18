import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/menu_item_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';

class ProductAddToCartBar extends StatelessWidget {
  final MenuItemModel product;
  final int quantity;
  final List<Map<String, dynamic>>? selectedToppings; // 👈 Thêm selectedToppings
  final bool canAdd;
  final VoidCallback onAddToCart;

  const ProductAddToCartBar({
    super.key,
    required this.product,
    required this.quantity,
    this.selectedToppings,
    this.canAdd = true,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    // 👈 Tính tổng giá đúng bao gồm toppings
    final basePrice = product.price * quantity;
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    final toppingsPrice = (selectedToppings ?? []).fold<double>(
      0.0,
      (sum, topping) => sum + _toDouble(topping['price']),
    ) * quantity;
    final totalPrice = basePrice + toppingsPrice;

    String _formatVND(int value) {
      final s = value.toString();
      if (s.length <= 3) return '$s VND';
      final buffer = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i != 0 && (s.length - i) % 3 == 0) buffer.write('.');
        buffer.write(s[i]);
      }
      return '${buffer.toString()} VND';
    }

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Container(
          padding: EdgeInsets.all(ScreenService.mediumSpacing),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng cộng:',
                        style: TextStyle(
                          fontSize: ScreenService.smallText,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        // 👈 Hiển thị tổng giá đúng với format
                        _formatVND(totalPrice.toInt()),
                        style: TextStyle(
                          fontSize: ScreenService.mediumText,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ScreenService.mediumSpacing),
                Expanded(
                  child: SizedBox(
                    height: ScreenService.buttonHeight,
                    child: ElevatedButton(
                      onPressed: (cartProvider.isLoading || !canAdd) ? null : onAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: cartProvider.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: ScreenService.smallSpacing),
                                Text(
                                  'Thêm',
                                  style: TextStyle(
                                    fontSize: ScreenService.mediumText,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}