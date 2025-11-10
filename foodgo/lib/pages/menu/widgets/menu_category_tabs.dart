import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constans/app_icons.dart';
import '../../../services/screen_service.dart';

class MenuCategoryTabs extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String selectedCategory;
  final Function(int) onCategoryChanged;

  const MenuCategoryTabs({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenService.buttonHeight + ScreenService.smallSpacing,
      padding: EdgeInsets.symmetric(vertical: ScreenService.smallSpacing / 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: ScreenService.smallSpacing),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category['id'] == selectedCategory;
          
          return Container(
            margin: EdgeInsets.only(right: ScreenService.smallSpacing),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) => onCategoryChanged(index),
              backgroundColor: AppColors.background,
              selectedColor: AppColors.primary.withOpacity(0.1),
              checkmarkColor: AppColors.primary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenService.mediumSpacing),
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 16,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    category['name'] as String? ?? 'Unknown',
                    style: TextStyle(
                      fontSize: ScreenService.smallText,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(Map<String, dynamic> category) {
    // First try to get icon from category data
    if (category['icon'] != null && category['icon'] is IconData) {
      return category['icon'] as IconData;
    }
    
    // Fallback to AppIcons based on category ID
    final categoryId = category['id'] as String? ?? '';
    return AppIcons.getIconData(categoryId);
  }
}


