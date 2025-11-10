import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../models/order_model.dart';
import 'order_status_badge.dart';

class OrderHistoryCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final VoidCallback onReorder;
  final VoidCallback? onRate;
  final VoidCallback? onCancel;

  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onReorder,
    this.onRate,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: screen.ScreenService.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(screen.ScreenService.mediumSpacing),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(screen.ScreenService.mediumSpacing),
        child: Padding(
          padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Restaurant info và status
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
                    child: Image.network(
                      order.restaurantImage ?? 'https://via.placeholder.com/50',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: screen.ScreenService.mediumSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.restaurantName,
                          style: TextStyle(
                            fontSize: screen.ScreenService.mediumText,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: screen.ScreenService.smallSpacing / 2),
                        Text(
                          _formatOrderDate(order.createdAt),
                          style: TextStyle(
                            fontSize: screen.ScreenService.smallText,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              
              SizedBox(height: screen.ScreenService.mediumSpacing),
              
              // Order info
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: screen.ScreenService.smallSpacing / 2),
                  Text(
                    'Mã đơn: ${order.id}',
                    style: TextStyle(
                      fontSize: screen.ScreenService.smallText,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screen.ScreenService.smallSpacing / 2),
              
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: screen.ScreenService.smallSpacing / 2),
                  Expanded(
                    child: Text(
                      order.deliveryAddressString,
                      style: TextStyle(
                        fontSize: screen.ScreenService.smallText,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              // Items count
              SizedBox(height: screen.ScreenService.smallSpacing / 2),
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: screen.ScreenService.smallSpacing / 2),
                  Text(
                    '${order.items.length} món',
                    style: TextStyle(
                      fontSize: screen.ScreenService.smallText,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: screen.ScreenService.mediumSpacing),
              
              // Total amount
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tổng tiền:',
                      style: TextStyle(
                        fontSize: screen.ScreenService.mediumText,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    order.formattedTotalWithDelivery,
                    style: TextStyle(
                      fontSize: screen.ScreenService.mediumText,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: screen.ScreenService.mediumSpacing),
              
              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel button (for pending/confirmed orders)
        if (onCancel != null && order.canCancel) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: Icon(
                Icons.cancel,
                size: 16,
                color: AppColors.error,
              ),
              label: Text(
                'Hủy đơn',
                style: TextStyle(
                  fontSize: screen.ScreenService.smallText,
                  color: AppColors.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error),
                padding: EdgeInsets.symmetric(
                  vertical: screen.ScreenService.smallSpacing / 2,
                ),
              ),
            ),
          ),
          SizedBox(width: screen.ScreenService.smallSpacing),
        ],
        
        // Reorder button
        if (order.canReorder) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onReorder,
              icon: Icon(
                Icons.repeat,
                size: 16,
                color: AppColors.primary,
              ),
              label: Text(
                'Đặt lại',
                style: TextStyle(
                  fontSize: screen.ScreenService.smallText,
                  color: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                padding: EdgeInsets.symmetric(
                  vertical: screen.ScreenService.smallSpacing / 2,
                ),
              ),
            ),
          ),
          SizedBox(width: screen.ScreenService.smallSpacing),
        ],
        
        // Rate or View detail button
        if (onRate != null && order.canRate) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onRate,
              icon: Icon(
                Icons.star,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                'Đánh giá',
                style: TextStyle(
                  fontSize: screen.ScreenService.smallText,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                padding: EdgeInsets.symmetric(
                  vertical: screen.ScreenService.smallSpacing / 2,
                ),
              ),
            ),
          ),
        ] else ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(
                Icons.visibility,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                'Xem chi tiết',
                style: TextStyle(
                  fontSize: screen.ScreenService.smallText,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  vertical: screen.ScreenService.smallSpacing / 2,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatOrderDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays <= 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}