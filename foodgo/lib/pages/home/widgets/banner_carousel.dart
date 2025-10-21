import 'package:flutter/material.dart';

class BannerCarousel extends StatelessWidget {
  final List<String> assets;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const BannerCarousel({super.key, required this.assets, required this.currentIndex, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: assets.length,
            onPageChanged: onPageChanged,
            itemBuilder: (_, i) => Image.asset(
              assets[i],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                assets.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == currentIndex ? scheme.primary : scheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}


