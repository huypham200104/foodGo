import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../services/screen_service.dart' as screen;

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      textInputAction: textInputAction ?? TextInputAction.next,
      maxLines: maxLines,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      // XÓA inputFormatters mặc định để cho phép nhập tiếng Việt
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
          borderSide: BorderSide(color: AppColors.textLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
          borderSide: BorderSide(color: AppColors.textLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
          borderSide: BorderSide(color: AppColors.textLight.withValues(alpha: 0.5)),
        ),
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: screen.ScreenService.smallText,
        ),
        hintStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: screen.ScreenService.smallText,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screen.ScreenService.mediumSpacing,
          vertical: screen.ScreenService.smallSpacing,
        ),
        alignLabelWithHint: maxLines != null && maxLines! > 1,
      ),
      style: TextStyle(
        fontSize: screen.ScreenService.mediumText,
        color: AppColors.textPrimary,
      ),
      validator: validator,
    );
  }
}

