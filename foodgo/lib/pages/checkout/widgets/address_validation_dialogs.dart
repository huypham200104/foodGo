import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class AddressValidationDialogs {
  static void showAddressRequiredDialog(
    BuildContext context, {
    required VoidCallback onSelectAddress,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Cần địa chỉ giao hàng'),
          ],
        ),
        content: Text(
          'Bạn cần chọn địa chỉ giao hàng để tiếp tục đặt hàng.',
          style: TextStyle(
            fontSize: screen.ScreenService.smallText,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onSelectAddress();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Chọn địa chỉ'),
          ),
        ],
      ),
    );
  }

  static void showPhoneRequiredDialog(
    BuildContext context, {
    required VoidCallback onUpdateAddress,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.phone, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Cần số điện thoại'),
          ],
        ),
        content: Text(
          'Địa chỉ được chọn chưa có số điện thoại. Vui lòng cập nhật số điện thoại để tiếp tục.',
          style: TextStyle(
            fontSize: screen.ScreenService.smallText,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onUpdateAddress();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cập nhật địa chỉ'),
          ),
        ],
      ),
    );
  }
}