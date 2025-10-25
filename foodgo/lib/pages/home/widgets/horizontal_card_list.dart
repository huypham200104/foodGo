import 'package:flutter/material.dart';

import 'food_card.dart';

class HorizontalCardList extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  const HorizontalCardList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final product = products[i];
          return FoodCard(
            imageUrl: product['imageUrl'] ?? '',
            name: product['name'] ?? '',
            price: product['price'] ?? '',
          );
        },
      ),
    );
  }
}


