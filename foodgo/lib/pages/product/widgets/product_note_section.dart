import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProductNoteSection extends StatelessWidget {
  final TextEditingController controller;

  const ProductNoteSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ghi chú (tùy chọn):',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Ví dụ: Ít cay, không hành...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}