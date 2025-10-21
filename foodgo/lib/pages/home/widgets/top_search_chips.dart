import 'package:flutter/material.dart';

class TopSearchChips extends StatelessWidget {
  const TopSearchChips({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> chips = const ['Món ăn dưới 80k', 'Đồ ăn chay', 'Combo no nê'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips
          .map((e) => ActionChip(
                label: Text(e),
                onPressed: () {},
              ))
          .toList(),
    );
  }
}


