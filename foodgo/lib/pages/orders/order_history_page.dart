import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../services/screen_service.dart' as screen;
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import 'widgets/order_history_app_bar.dart';
import 'widgets/order_history_loading.dart';
import 'widgets/order_history_error.dart';
import 'widgets/order_history_empty.dart';
import 'widgets/order_status_filter.dart';
import 'widgets/order_history_list.dart';
import 'widgets/order_detail_dialog.dart';
import 'widgets/order_rating_dialog.dart';
import 'widgets/order_cancel_dialog.dart';
import 'widgets/empty_orders_widget.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool _isScreenServiceInitialized = false;
  String _selectedStatus = 'all';
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isScreenServiceInitialized) {
      screen.ScreenService.init(context);
      _isScreenServiceInitialized = true;
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      
      if (userId != null) {
        final orders = await OrderService.getUserOrders(userId);
        setState(() {
          _orders = orders;
        });
      } else {
        setState(() {
          _errorMessage = 'Vui lòng đăng nhập để xem đơn hàng';
        });
      }
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        _errorMessage = 'Không thể tải đơn hàng. Vui lòng thử lại.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<OrderModel> get _filteredOrders {
    if (_selectedStatus == 'all') return _orders;
    return _orders.where((order) => order.status == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OrderHistoryAppBar(
        onBack: () => Navigator.pop(context),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const OrderHistoryLoading();
    }
    
    if (_errorMessage != null) {
      return OrderHistoryError(
        message: _errorMessage!,
        onRetry: _loadOrders,
      );
    }
    
    if (_orders.isEmpty) {
      return const EmptyOrdersWidget();
    }
    
    return Column(
      children: [
        // Status filter
        OrderStatusFilter(
          selectedStatus: _selectedStatus,
          onStatusChanged: (status) {
            setState(() => _selectedStatus = status);
          },
        ),
        
        // Orders list
        Expanded(
          child: _filteredOrders.isEmpty
              ? const OrderHistoryEmpty(
                  message: 'Không tìm thấy đơn hàng với trạng thái này'
                )
              : OrderHistoryList(
                  orders: _filteredOrders,
                  onRefresh: _loadOrders,
                  onOrderTap: _viewOrderDetail,
                  onReorder: _reorder,
                  onRate: _rateOrder,
                  onCancel: _cancelOrder,
                ),
        ),
      ],
    );
  }

  void _viewOrderDetail(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailDialog(order: order),
    );
  }

  Future<void> _reorder(OrderModel order) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vui lòng đăng nhập để đặt lại đơn hàng'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đang thêm món vào giỏ hàng...'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 1),
        ),
      );

      await cartProvider.addItems(order.items, userId: userId);
      
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.cart);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể đặt lại đơn hàng: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rateOrder(OrderModel order) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => OrderRatingDialog(order: order),
    );

    if (result != null) {
      try {
        await OrderService.rateOrder(
          order.id, 
          result['rating'] as double, 
          result['comment'] as String?,
        );
        _loadOrders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đánh giá thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Không thể đánh giá'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _cancelOrder(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => OrderCancelDialog(order: order),
    );

    if (confirmed == true) {
      try {
        await OrderService.cancelOrder(order.id, 'Hủy bởi người dùng');
        _loadOrders(); // Refresh orders
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã hủy đơn hàng thành công'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Không thể hủy đơn hàng'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
