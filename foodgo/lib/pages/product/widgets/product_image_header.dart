import 'package:flutter/material.dart';
import '../../../widgets/network_image_with_fallback.dart';

class ProductImageHeader extends StatelessWidget {
  final String imageUrl;

  const ProductImageHeader({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        background: NetworkImageWithFallback(
          imageUrl: imageUrl,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
