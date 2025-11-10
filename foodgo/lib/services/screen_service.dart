import 'package:flutter/material.dart';

class ScreenService {
  static late MediaQueryData _mediaQuery;
  static late Size _screenSize;
  static late EdgeInsets _padding;
  
  /// Initialize screen service - gọi trong main app
  static void init(BuildContext context) {
    _mediaQuery = MediaQuery.of(context);
    _screenSize = _mediaQuery.size;
    _padding = _mediaQuery.padding;
  }

  /// Screen dimensions
  static double get width => _screenSize.width;
  static double get height => _screenSize.height;
  
  /// Screen categories
  static bool get isSmallScreen => width < 360;
  static bool get isMediumScreen => width >= 360 && width < 414;
  static bool get isLargeScreen => width >= 414;
  
  /// Screen ratios for responsive design
  static double get screenRatio => height / width;
  static bool get isTallScreen => screenRatio > 2.0;
  
  /// Safe area paddings
  static double get topPadding => _padding.top;
  static double get bottomPadding => _padding.bottom;
  static double get leftPadding => _padding.left;
  static double get rightPadding => _padding.right;
  
  /// Available content area (minus safe areas)
  static double get availableHeight => height - topPadding - bottomPadding;
  static double get availableWidth => width - leftPadding - rightPadding;
  
  /// Responsive spacing
  static double get smallSpacing => isSmallScreen ? 8 : 16;
  static double get mediumSpacing => isSmallScreen ? 16 : 24;
  static double get largeSpacing => isSmallScreen ? 24 : 32;
  
  /// Responsive text sizes
  static double get smallText => isSmallScreen ? 12 : 14;
  static double get mediumText => isSmallScreen ? 14 : 16;
  static double get largeText => isSmallScreen ? 18 : 20;
  static double get titleText => isSmallScreen ? 24 : 28;
  
  /// Responsive button heights
  static double get buttonHeight => isSmallScreen ? 48 : 56;
  static double get smallButtonHeight => isSmallScreen ? 40 : 44;
  
  /// Responsive form spacing
  static double get formSpacing => isSmallScreen ? 12 : 16;
  static double get sectionSpacing => isSmallScreen ? 20 : 24;
  
  /// Percentage-based dimensions
  static double widthPercent(double percent) => width * (percent / 100);
  static double heightPercent(double percent) => height * (percent / 100);
  
  /// Update when screen rotates or resizes
  static void update(BuildContext context) {
    init(context);
  }
}