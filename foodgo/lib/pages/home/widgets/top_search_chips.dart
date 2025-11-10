import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';

class TopSearchChips extends StatelessWidget {
  final Function(String)? onChipTap;

  const TopSearchChips({
    super.key,
    this.onChipTap,
  });

  @override
  Widget build(BuildContext context) {
    final keywords = [
      {'text': 'Món ăn dưới 80k', 'icon': '💰'},
      {'text': 'Đồ ăn chay', 'icon': '🥗'},
      {'text': 'Combo no nê', 'icon': '🍱'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top tìm kiếm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: keywords.map((keyword) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: ActionChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          keyword['icon']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          keyword['text']!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () => onChipTap?.call(keyword['text']!),
                    backgroundColor: AppColors.primary, // Sử dụng AppColors.primary thay vì secondary
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    labelPadding: EdgeInsets.zero,
                    elevation: 3,
                    shadowColor: AppColors.shadowMedium,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

