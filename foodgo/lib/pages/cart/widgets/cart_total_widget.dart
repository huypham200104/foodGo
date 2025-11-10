import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart';

class CartTotalWidget extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;
  
  const CartTotalWidget({
    Key? key,
    required this.total,
    required this.onCheckout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        ScreenService.mediumSpacing,
        ScreenService.smallSpacing,
        ScreenService.mediumSpacing,
        ScreenService.smallSpacing,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tổng cộng',
                    style: TextStyle(
                      fontSize: ScreenService.smallText,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: ScreenService.smallSpacing / 2),
                  Text(
                    _formatVnd(total),
                    style: TextStyle(
                      fontSize: ScreenService.largeText,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: ScreenService.widthPercent(40),
              height: ScreenService.buttonHeight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
                ),
                child: ElevatedButton(
                  onPressed: onCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
                    ),
                  ),
                  child: Text(
                    'Đặt hàng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenService.mediumText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatVnd(double value) {
    final s = value.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i - 1;
      buf.write(s[i]);
      if (posFromEnd > 0 && posFromEnd % 3 == 0) buf.write('.');
    }
    return '${buf.toString()} đ';
  }
}

// Removed duplicate ScreenService; use the shared one from services/screen_service.dart