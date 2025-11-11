import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../services/order_service.dart';
import '../../../models/order_model.dart';
import 'order_history_card.dart';

class OrderHistoryList extends StatelessWidget {
  final List<OrderModel> orders;
  final Future<void> Function() onRefresh;
  final Function(OrderModel) onOrderTap;
  final Function(OrderModel) onReorder;
  final Function(OrderModel) onRate;
  final Function(OrderModel) onCancel;

  const OrderHistoryList({
    super.key,
    required this.orders,
    required this.onRefresh,
    required this.onOrderTap,
    required this.onReorder,
    required this.onRate,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderHistoryCard(
            order: order,
            onTap: () => onOrderTap(order),
            onReorder: () => onReorder(order),
            onRate: OrderService.canRateOrder(order) 
                ? () => onRate(order) 
                : null,
            onCancel: OrderService.canCancelOrder(order)
                ? () => onCancel(order)
                : null,
          );
        },
      ),
    );
  }
}