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
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use SingleChildScrollView to prevent overflow when keyboard appears
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: AppColors.warning, size: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Đánh giá đơn hàng',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
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
            const SizedBox(height: 16),
            // Comment TextField
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Nhập nhận xét của bạn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _selectedRating > 0 
              ? () {
                  Navigator.pop(context, {
                    'rating': _selectedRating.toDouble(),
                    'comment': _commentController.text.trim(),
                  });
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Gửi đánh giá'),
        ),
      ],
    );
  }
}
