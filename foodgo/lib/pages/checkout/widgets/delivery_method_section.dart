import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DeliveryMethodSection extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodChanged;

  const DeliveryMethodSection({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phương thức nhận hàng', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMethodOption(
                  'Giao hàng', 
                  'delivery', 
                  Icons.delivery_dining
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildMethodOption(
                  'Tại quán', 
                  'pickup', 
                  Icons.store
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodOption(String title, String value, IconData icon) {
    bool isSelected = selectedMethod == value;
    return InkWell(
      onTap: () => onMethodChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


