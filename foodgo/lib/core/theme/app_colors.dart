import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8A5A);
  static const Color primaryDark = Color(0xFFE55A2B);
  
  // Secondary colors - Thêm các color này
  static const Color secondary = Color(0xFF6C63FF);
  static const Color secondaryLight = Color(0xFF8B7FFF);
  static const Color secondaryDark = Color(0xFF5048E5);
  
  // Background colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Text colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFBDC3C7);
  
  // Status colors
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);
  
  // Shadow colors
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x29000000);
  
  // Accent colors
  static const Color accent = Color(0xFF8E44AD);
  static const Color accentLight = Color(0xFFAB7AC8);
  
  // Transparent colors
  static const Color transparent = Colors.transparent;
  
  // Border colors
  static const Color border = Color(0xFFE1E8ED);
  static const Color borderLight = Color(0xFFF0F3F7);
  
  // Gradients
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8F9FA), Color(0xFFE3F2FD)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8F9FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Thêm secondary gradient
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF2ECC71)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, Color(0xFFF1C40F)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, Color(0xFFC0392B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Utility Decorations (moved from app_gradients.dart)
  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    gradient: buttonGradient,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: shadowLight,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration get circleButtonDecoration => BoxDecoration(
    gradient: primaryGradient,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: primary.withOpacity(0.25),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration get cardDecoration => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: shadowLight,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );
}