import 'package:flutter/material.dart';

class NetworkImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String fallbackAsset;
  final Widget? placeholder;
  final Widget? errorWidget;

  const NetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackAsset = 'assets/other/no_image.png',
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // If imageUrl is empty or null, show fallback immediately
    if (imageUrl.isEmpty) {
      return _buildFallbackImage();
    }

    // If it's a local asset path, use Image.asset
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
      );
    }

    // If it's a network URL, use Image.network with fallback
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildLoadingPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildFallbackImage();
      },
    );
  }

  Widget _buildFallbackImage() {
    return Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: fit,
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Specialized widgets for common use cases
class FoodImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const FoodImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return NetworkImageWithFallback(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
    );
  }
}

class AvatarImage extends StatelessWidget {
  final String imageUrl;
  final double? size;
  final BoxFit fit;

  const AvatarImage({
    super.key,
    required this.imageUrl,
    this.size,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: NetworkImageWithFallback(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: fit,
      ),
    );
  }
}

class RestaurantImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const RestaurantImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: NetworkImageWithFallback(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}
