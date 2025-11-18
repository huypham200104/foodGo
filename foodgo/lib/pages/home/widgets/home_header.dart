import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../services/screen_service.dart';
import 'top_bar.dart';
import 'banner_carousel.dart';

class HomeHeader extends StatelessWidget {
  final List<String> bannerImageUrls;

  const HomeHeader({
    super.key,
    required this.bannerImageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Bar
        TopBar(
          onNotificationTap: () =>
              Navigator.pushNamed(context, AppRoutes.notification),
          onProfileTap: () =>
              Navigator.pushNamed(context, AppRoutes.profile),
          onToggleTheme: () {},
        ),

        // Banner Carousel
        Container(
          height: ScreenService.isSmallScreen ? 160 : 200,
          margin: EdgeInsets.symmetric(
            horizontal: ScreenService.mediumSpacing,
            vertical: ScreenService.smallSpacing,
          ),
          child: BannerCarousel(
            imageUrls: bannerImageUrls,
            onBannerTap: (index) {
              print('Banner $index tapped');
            },
          ),
        ),
      ],
    );
  }
}
