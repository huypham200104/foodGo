import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  // Button gradients
  static BoxDecoration get buttonDecoration => BoxDecoration(
    gradient: const LinearGradient(
      colors: [AppColors.primary, AppColors.primaryLight],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(8),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration get circleButtonDecoration => BoxDecoration(
    gradient: const LinearGradient(
      colors: [AppColors.primary, AppColors.primaryLight],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    shape: BoxShape.circle,
    boxShadow: const [
      BoxShadow(
        color: Color(0x40FF6B35),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration get backgroundDecoration => const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFF8F9FA), Color(0xFFE3F2FD)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );
  
  static BoxDecoration get cardDecoration => BoxDecoration(
    gradient: const LinearGradient(
      colors: [Colors.white, Color(0xFFF8F9FA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );
}