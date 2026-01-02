import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? screen.ScreenService.smallSpacing / 2 : screen.ScreenService.smallSpacing,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: statusInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
        border: Border.all(
          color: statusInfo.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo.icon,
            size: isSmall ? 12 : 14,
            color: statusInfo.color,
          ),
          SizedBox(width: screen.ScreenService.smallSpacing / 2),
          Text(
            statusInfo.label,
            style: TextStyle(
              fontSize: isSmall 
                  ? screen.ScreenService.smallText - 2
                  : screen.ScreenService.smallText,
              fontWeight: FontWeight.w600,
              color: statusInfo.color,
            ),
          ),
        ],
      ),
    );
  }

  StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return StatusInfo(
          label: 'Chờ xác nhận',
          color: AppColors.warning,
          icon: Icons.access_time,
        );
      case 'confirmed':
        return StatusInfo(
          label: 'Đã xác nhận',
          color: AppColors.info,
          icon: Icons.check_circle,
        );
      case 'preparing':
        return StatusInfo(
          label: 'Đang chuẩn bị',
          color: AppColors.secondary,
          icon: Icons.restaurant,
        );
      case 'delivering':
        return StatusInfo(
          label: 'Đang giao',
          color: AppColors.primary,
          icon: Icons.delivery_dining,
        );
      case 'delivered':
        return StatusInfo(
          label: 'Đã giao',
          color: AppColors.success,
          icon: Icons.check_circle,
        );
      case 'cancelled':
        return StatusInfo(
          label: 'Đã hủy',
          color: AppColors.error,
          icon: Icons.cancel,
        );
      default:
        return StatusInfo(
          label: 'Không xác định',
          color: AppColors.textSecondary,
          icon: Icons.help,
        );
    }
  }
}

class StatusInfo {
  final String label;
  final Color color;
  final IconData icon;

  StatusInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}

