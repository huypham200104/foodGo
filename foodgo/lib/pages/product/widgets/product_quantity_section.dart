import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProductQuantitySection extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const ProductQuantitySection({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Số lượng:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Row(
          children: [
            IconButton(
              onPressed: quantity > 1 ? () {
                onQuantityChanged(quantity - 1);
              } : null,
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[100],
                shape: const CircleBorder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '$quantity',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                onQuantityChanged(quantity + 1);
              },
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}