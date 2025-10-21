import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - Màu cam đỏ ấm áp cho food app
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8C5A);
  static const Color primaryDark = Color(0xFFE85A2A);

  // Background colors - Gradient ấm áp
  static const Color background = Color(0xFFFFFBF5);
  static const Color surface = Colors.white;

  // Input colors
  static const Color inputFill = Color(0xFFF8F4EF);

  // Text colors
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9C9AA3);

  // Shadow
  static final Color shadow12 = Colors.black.withOpacity(0.08);

  // Gradients
  static const LinearGradient authHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B35), // Orange
      Color(0xFFFF8E53), // Light Orange
      Color(0xFFFFA06E), // Peach
    ],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF6B35),
      Color(0xFFFF8E53),
    ],
  );

  // New gradients for improved design
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFF9F4A),
      Color(0xFFFFC26F),
      Color(0xFFFFE8B8),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF6B35),
      Color(0xFFFF8E53),
    ],
  );
}