import 'package:flutter/material.dart';

import 'food_card.dart';

class HorizontalCardList extends StatelessWidget {
  final List<String> assets;
  const HorizontalCardList({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: assets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => FoodCard(asset: assets[i]),
      ),
    );
  }
}


