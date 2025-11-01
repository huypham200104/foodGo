import 'package:flutter/material.dart';
import '../../../models/menu_item_model.dart';
import '../../../core/theme/app_colors.dart';

class ProductInfoSection extends StatelessWidget {
  final MenuItemModel product;

  const ProductInfoSection({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tên và giá
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${product.price.toStringAsFixed(0)}đ',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Mô tả
        Text(
          product.description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}