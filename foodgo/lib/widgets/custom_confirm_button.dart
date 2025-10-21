import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CustomConfirmButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final bool showShadow;
  final String? loadingText;

  const CustomConfirmButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.padding,
    this.gradient,
    this.showShadow = true,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    final bool canPress = isEnabled && !isLoading && onPressed != null;
    
    return Container(
      width: width,
      height: height ?? 50,
      decoration: BoxDecoration(
        gradient: gradient ?? (backgroundColor != null ? null : AppColors.buttonGradient),
        color: gradient == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow && canPress
            ? [
                BoxShadow(
                  color: (gradient != null ? AppColors.primary : backgroundColor ?? AppColors.primary)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: canPress ? onPressed : null,
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            alignment: Alignment.center,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
          if (loadingText != null) ...[
            const SizedBox(width: 12),
            Text(
              loadingText!,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: textColor ?? Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Predefined button styles
class CustomConfirmButtonStyles {
  static CustomConfirmButton primary({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    IconData? icon,
    double? width,
    double? height,
  }) {
    return CustomConfirmButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      width: width,
      height: height,
      gradient: AppColors.buttonGradient,
    );
  }

  static CustomConfirmButton success({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    IconData? icon,
    double? width,
    double? height,
  }) {
    return CustomConfirmButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      width: width,
      height: height,
      backgroundColor: Colors.green,
      gradient: const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
      ),
    );
  }

  static CustomConfirmButton danger({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    IconData? icon,
    double? width,
    double? height,
  }) {
    return CustomConfirmButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      width: width,
      height: height,
      backgroundColor: Colors.red,
      gradient: const LinearGradient(
        colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
      ),
    );
  }

  static CustomConfirmButton warning({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    IconData? icon,
    double? width,
    double? height,
  }) {
    return CustomConfirmButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      width: width,
      height: height,
      backgroundColor: Colors.orange,
      gradient: const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
      ),
    );
  }

  static CustomConfirmButton outline({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    IconData? icon,
    double? width,
    double? height,
    Color borderColor = AppColors.primary,
    Color textColor = AppColors.primary,
  }) {
    return CustomConfirmButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      width: width,
      height: height,
      backgroundColor: Colors.transparent,
      textColor: textColor,
      showShadow: false,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }
}

