import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class NetworkImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const NetworkImageWithFallback({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildFallback();
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoading();
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildFallback();
      },
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.fastfood,
        // Guard against unbounded sizes: if width/height are not finite,
        // fall back to a sensible icon size.
        size: (() {
          final w = width;
          final h = height;
          double base;
          if (w.isFinite && w > 0) {
            base = w;
          } else if (h.isFinite && h > 0) {
            base = h;
          } else {
            base = 48.0;
          }
          // Use 40% of the base size but ensure it's finite and >= 16
          final s = base * 0.4;
          if (!s.isFinite || s <= 0) return 24.0;
          return s.clamp(16.0, 128.0);
        })(),
        color: AppColors.textLight,
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
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
      width: width ?? 100, // Provide default values
      height: height ?? 100, // Provide default values
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
    final avatarSize = size ?? 50; // Provide default size
    return ClipOval(
      child: NetworkImageWithFallback(
        imageUrl: imageUrl,
        width: avatarSize,
        height: avatarSize,
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
        width: width ?? 200, // Provide default values
        height: height ?? 150, // Provide default values
        fit: fit,
      ),
    );
  }
}
