import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../models/order_model.dart';

class OrderRatingDialog extends StatefulWidget {
  final OrderModel order;

  const OrderRatingDialog({
    super.key,
    required this.order,
  });

  @override
  State<OrderRatingDialog> createState() => _OrderRatingDialogState();
}

class _OrderRatingDialogState extends State<OrderRatingDialog> {
  int _selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(Icons.star, color: AppColors.warning),
          const SizedBox(width: 8),
          const Text('Đánh giá đơn hàng'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bạn cảm thấy đơn hàng này như thế nào?',
            style: TextStyle(
              fontSize: screen.ScreenService.smallText,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                  Navigator.pop(context, _selectedRating.toDouble());
                },
                icon: Icon(
                  Icons.star,
                  color: _selectedRating > index 
                      ? AppColors.warning 
                      : AppColors.textLight,
                  size: 32,
                ),
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}