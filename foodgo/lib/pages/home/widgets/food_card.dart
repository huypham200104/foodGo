import 'package:flutter/material.dart';
import '../../../widgets/network_image_with_fallback.dart';
import '../../../models/menu_item_model.dart';
import '../../product/product_detail_page.dart';

class FoodCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;
  final MenuItemModel? product;
  
  const FoodCard({
    super.key, 
    required this.imageUrl,
    required this.name,
    required this.price,
    this.product,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 140,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: product != null ? () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: product!),
              ),
            );
          } : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: scheme.surfaceContainerHighest,
                  child: FoodImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(price, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


