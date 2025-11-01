import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFFFF8C42); // Thêm màu secondary
  
  // Background colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  
  // Accent colors
  static const Color accent = Color(0xFF00B894);
  static const Color error = Color(0xFFE17055);
  static const Color warning = Color(0xFFFDCB6E);
  
  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B35),
      Color(0xFFFF8C42),
    ],
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF6B35),
      Color(0xFFFF8C42),
    ],
  );
}