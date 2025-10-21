import 'package:flutter/material.dart';
import 'package:foodgo/core/theme/app_colors.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.icon, // ✅ thêm icon
  });

  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? icon; // ✅ thêm dòng này

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontFamily: 'Nunito'),
      decoration: InputDecoration(
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.primary)
            : null, // ✅ thêm icon ở đây
        hintText: hintText,
        hintStyle: const TextStyle(fontFamily: 'Nunito'),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
