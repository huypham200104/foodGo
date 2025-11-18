import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';
import '../../../models/menu_item_model.dart';
import 'product_options_section.dart';
// price breakdown moved to bottom add-to-cart bar

class ProductDetailsSection extends StatelessWidget {
  final MenuItemModel product;
  final int quantity;
  final List<ToppingOption> selectedToppings;
  final Function(List<ToppingOption>) onToppingsChanged;

  const ProductDetailsSection({
    super.key,
    required this.product,
    required this.quantity,
    required this.selectedToppings,
    required this.onToppingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // 👈 Thu nhỏ column
      children: [
        // Product basic info
        _ProductBasicInfo(product: product),
        
        SizedBox(height: ScreenService.mediumSpacing),
        
        // Toppings - sử dụng ProductOptionsSection (maps) — chuyển đổi giữa
        // ToppingOption <-> Map<String,dynamic>
        SizedBox(
          width: ScreenService.availableWidth,
          height: ScreenService.availableHeight * 0.35,
          child: ProductOptionsSection(
            // pass toppings as serializable maps so the simplified widget can
            // read name/price consistently
            toppings: product.effectiveToppingOptions
                .map((t) => t.toJson())
                .toList(),
            selectedToppings:
                selectedToppings.map((t) => t.toJson()).toList(),
            onSizeChanged: (_) {},
            onToppingsChanged: (maps) {
              // convert back to ToppingOption list for the parent callback
              final list = maps.map((m) => ToppingOption.fromJson(m)).toList();
              onToppingsChanged(list);
            },
          ),
        ),
        
        SizedBox.shrink(),
      ],
    );
  }
}

class _ProductBasicInfo extends StatelessWidget {
  final MenuItemModel product;

  const _ProductBasicInfo({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name
        Text(
          product.name,
          style: TextStyle(
            fontSize: ScreenService.largeText,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        SizedBox(height: ScreenService.smallSpacing),
        
        // Product description
        Text(
          product.description,
          style: TextStyle(
            fontSize: ScreenService.mediumText,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        
        SizedBox(height: ScreenService.smallSpacing),
        
        // Category and status badges
        Row(
          children: [
            _CategoryBadge(category: product.categoryInfo),
            SizedBox(width: ScreenService.smallSpacing),
            if (product.isNew) _StatusBadge(text: 'MỚI', color: AppColors.success),
            if (product.isBestseller) _StatusBadge(text: 'BÁN CHẠY', color: AppColors.warning),
          ],
        ),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final CategoryInfo category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenService.smallSpacing,
        vertical: ScreenService.smallSpacing / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.toString(),
        style: TextStyle(
          fontSize: ScreenService.smallText - 2,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenService.smallSpacing,
        vertical: ScreenService.smallSpacing / 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenService.smallText - 2,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
