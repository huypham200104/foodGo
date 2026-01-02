import 'package:flutter/material.dart';

class HorizontalCardList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) cardBuilder;
  final double? height;
  final String emptyMessage;

  const HorizontalCardList({
    super.key,
    required this.items,
    required this.cardBuilder,
    this.height,
    this.emptyMessage = 'Không có sản phẩm',
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        height: height ?? 200,
        child: Center(
          child: Text(
            emptyMessage,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Container(
      height: height ?? 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index == items.length - 1 ? 0 : 8,
            ),
            child: cardBuilder(items[index]),
          );
        },
      ),
    );
  }
}

