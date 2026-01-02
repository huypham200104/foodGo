import 'package:flutter/material.dart';
import '../../../models/cart_item_model.dart';
import '../../../widgets/network_image_with_fallback.dart';
import '../../../services/screen_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';

class CartItemTile extends StatelessWidget {
  final CartItemModel cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemTile({
    Key? key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
      ),
      child: Padding(
        padding: EdgeInsets.all(ScreenService.smallSpacing),
        child: Row(
          children: [
            // Hình ảnh sản phẩm
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenService.smallSpacing / 2),
              child: NetworkImageWithFallback(
                imageUrl: cartItem.item.imageUrl,
                width: ScreenService.buttonHeight,
                height: ScreenService.buttonHeight,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: ScreenService.smallSpacing),

            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.item.name,
                    style: TextStyle(
                      fontSize: ScreenService.mediumText,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ScreenService.smallSpacing / 2),
                  Text(
                    formatVnd(cartItem.item.price),
                    style: TextStyle(
                      fontSize: ScreenService.smallText,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Selected toppings display
                  if (cartItem.selectedToppings.isNotEmpty) ...[
                    SizedBox(height: ScreenService.smallSpacing / 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: cartItem.selectedToppings.map((t) {
                        final name = t['name']?.toString() ?? '';
                        final price = t['price'];
                        final priceNum = (price is num) ? price : (double.tryParse(price?.toString() ?? '') ?? 0.0);
                        final label = priceNum > 0 ? '$name · ${formatVnd(priceNum)}' : name;
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: ScreenService.smallText - 1,
                              color: Colors.grey[800],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (cartItem.note.isNotEmpty) ...[
                    SizedBox(height: ScreenService.smallSpacing / 2),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenService.smallSpacing / 2,
                        vertical: ScreenService.smallSpacing / 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Ghi chú: ${cartItem.note}',
                        style: TextStyle(
                          fontSize: ScreenService.smallText - 1,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Điều khiển số lượng
            Column(
              children: [
                _buildQuantityControls(),
                SizedBox(height: ScreenService.smallSpacing),
                _buildRemoveButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: cartItem.quantity > 1 
                ? () => onQuantityChanged(cartItem.quantity - 1)
                : null,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenService.smallSpacing,
              vertical: ScreenService.smallSpacing / 2,
            ),
            child: Text(
              '${cartItem.quantity}',
              style: TextStyle(
                fontSize: ScreenService.mediumText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () => onQuantityChanged(cartItem.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
      child: Container(
        padding: EdgeInsets.all(ScreenService.smallSpacing / 2),
        child: Icon(
          icon,
          size: 20,
          color: onPressed != null ? AppColors.primary : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenService.smallSpacing,
          vertical: ScreenService.smallSpacing / 2,
        ),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(ScreenService.smallSpacing / 2),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_outline,
              size: 16,
              color: Colors.red[600],
            ),
            SizedBox(width: 4),
            Text(
              'Xóa',
              style: TextStyle(
                fontSize: ScreenService.smallText,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
}
