import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../models/order_model.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/date_formatter.dart'; // 👈 Import DateFormatter

class OrderInfoSection extends StatelessWidget {
  final OrderModel order;

  const OrderInfoSection({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow('Trạng thái', _getStatusText(order.status)),
        _buildInfoRow('Ngày đặt', DateFormatter.formatOrderDate(order.createdAt)), // 👈 Sử dụng DateFormatter
        _buildInfoRow('Tổng tiền', CurrencyFormatter.format(order.totalPrice)), // 👈 Sử dụng totalPrice
        // 👈 Thêm thông tin chi tiết
        if (order.deliveryFee > 0)
          _buildInfoRow('Phí giao hàng', CurrencyFormatter.format(order.deliveryFee)),
        _buildInfoRow('Tổng cộng', CurrencyFormatter.format(order.totalAmount)), // 👈 Sử dụng totalAmount (có phí ship)
      ],
    );
  } 

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screen.ScreenService.smallSpacing / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: screen.ScreenService.smallText,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: screen.ScreenService.smallText,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) { // 👈 Thêm toLowerCase() để handle case variations
      case 'pending': return 'Chờ xác nhận';
      case 'confirmed': return 'Đã xác nhận';
      case 'preparing': return 'Đang chuẩn bị';
      case 'delivering':
      case 'on_delivery': return 'Đang giao hàng';
      case 'completed':
      case 'delivered': return 'Đã giao hàng';
      case 'cancelled': return 'Đã hủy';
      default: return status;
    }
  }
}