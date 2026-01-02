import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';

class BannerCarousel extends StatefulWidget {
  final Function(int)? onBannerTap;
  final List<String>? imageUrls;

  const BannerCarousel({
    super.key,
    this.onBannerTap,
    this.imageUrls,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;
  
  // Asset banners từ voucher folder
  final List<String> _defaultBanners = [
    'assets/voucher/voucher1.jpg',
    'assets/voucher/voucher2.jpg',
    'assets/voucher/voucher3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    final banners = widget.imageUrls?.isNotEmpty == true ? widget.imageUrls! : _defaultBanners;
    if (banners.isEmpty) return;
    
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && mounted) {
        int nextPage = (_currentIndex + 1) % banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenService.init(context);
    final banners = widget.imageUrls?.isNotEmpty == true ? widget.imageUrls! : _defaultBanners;
    
    if (banners.isEmpty) {
      return Container(
        width: double.infinity, // Chiếm hết chiều ngang
        height: ScreenService.isSmallScreen ? 160 : 200,
        margin: EdgeInsets.symmetric(vertical: ScreenService.smallSpacing),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0), // Không bo góc để chiếm hết
          gradient: AppColors.primaryGradient,
        ),
        child: _buildPlaceholder(),
      );
    }
    
    return Container(
      width: double.infinity, // Chiếm hết chiều ngang
      height: ScreenService.isSmallScreen ? 160 : 200,
      margin: EdgeInsets.symmetric(vertical: ScreenService.smallSpacing),
      child: Stack(
        children: [
          // PageView với các banner - full width
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                widget.onBannerTap?.call(index);
              },
              itemCount: banners.length,
              itemBuilder: (context, index) {
                return _buildBannerItem(banners[index], index);
              },
            ),
          ),
          
          // Gradient overlay để làm nổi bật nội dung
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          
          // Dots indicator
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: banners.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentIndex == entry.key ? 32 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentIndex == entry.key 
                        ? Colors.white 
                        : Colors.white.withValues(alpha: 0.4),
                    boxShadow: _currentIndex == entry.key ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Promotion label
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.warningGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🔥',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'KHUYẾN MÃI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Banner counter
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentIndex + 1}/${banners.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(String imagePath, int index) {
    final isAsset = !imagePath.startsWith('http');
    
    return Container(
      width: double.infinity, // Chiếm hết chiều ngang
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: isAsset
          ? Image.asset(
              imagePath,
              fit: BoxFit.cover, // Cover để lấp đầy container
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading asset image: $imagePath - $error');
                return _buildPlaceholder();
              },
            )
          : Image.network(
              imagePath,
              fit: BoxFit.cover, // Cover để lấp đầy container
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('Error loading network image: $imagePath - $error');
                return _buildPlaceholder();
              },
            ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer,
                size: 40,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Khuyến mãi hấp dẫn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tiết kiệm tới 50%',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Đặt ngay!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

