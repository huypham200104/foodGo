import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class OrderStatusFilter extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const OrderStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  static const List<FilterOption> _options = [
    FilterOption(value: 'all', label: 'Tất cả'),
    FilterOption(value: 'pending', label: 'Chờ xác nhận'),
    FilterOption(value: 'preparing', label: 'Đang chuẩn bị'),
    FilterOption(value: 'delivering', label: 'Đang giao'),
    FilterOption(value: 'delivered', label: 'Đã giao'),
    FilterOption(value: 'cancelled', label: 'Đã hủy'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: screen.ScreenService.smallSpacing),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: screen.ScreenService.mediumSpacing),
        itemCount: _options.length,
        itemBuilder: (context, index) {
          final option = _options[index];
          final isSelected = selectedStatus == option.value;
          
          return Container(
            margin: EdgeInsets.only(
              right: screen.ScreenService.smallSpacing,
            ),
            child: FilterChip(
              label: Text(
                option.label,
                style: TextStyle(
                  fontSize: screen.ScreenService.smallText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) => onStatusChanged(option.value),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.textLight,
                width: 1,
              ),
              showCheckmark: false,
              padding: EdgeInsets.symmetric(
                horizontal: screen.ScreenService.mediumSpacing,
                vertical: screen.ScreenService.smallSpacing / 2,
              ),
            ),
          );
        },
      ),
    );
  }
}

class FilterOption {
  final String value;
  final String label;

  const FilterOption({
    required this.value,
    required this.label,
  });
}