import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/screen_service.dart' as screen;

enum ButtonType { primary, secondary, text, outline }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? screen.ScreenService.buttonHeight;
    
    if (isLoading) {
      return SizedBox(
        width: width,
        height: buttonHeight,
        child: _buildLoadingButton(),
      );
    }

    switch (type) {
      case ButtonType.primary:
        return _buildPrimaryButton(buttonHeight);
      case ButtonType.secondary:
        return _buildSecondaryButton(buttonHeight);
      case ButtonType.text:
        return _buildTextButton();
      case ButtonType.outline:
        return _buildOutlineButton(buttonHeight);
    }
  }

  Widget _buildPrimaryButton(double buttonHeight) {
    return SizedBox(
      width: width,
      height: buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(
          text,
          style: TextStyle(
            fontSize: screen.ScreenService.mediumText,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.textLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(double buttonHeight) {
    return SizedBox(
      width: width,
      height: buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(
          text,
          style: TextStyle(
            fontSize: screen.ScreenService.mediumText,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.textLight.withOpacity(0.1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton(double buttonHeight) {
    return SizedBox(
      width: width,
      height: buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(
          text,
          style: TextStyle(
            fontSize: screen.ScreenService.mediumText,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton() {
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon ?? const SizedBox.shrink(),
      label: Text(
        text,
        style: TextStyle(
          fontSize: screen.ScreenService.smallText,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
        ),
      ),
      child: const CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    );
  }
}