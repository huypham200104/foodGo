import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart'; // Import AppRoutes
import '../../services/screen_service.dart' as screen;
import '../../services/order_service.dart'; // Import OrderService
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import 'widgets/order_history_card.dart';
import 'widgets/order_status_filter.dart';
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
      appBar: AppBar(
        title: Text(
          'Đơn hàng của tôi',
          style: TextStyle(
            fontSize: screen.ScreenService.largeText,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }
    
    if (_errorMessage != null) {
      return _buildErrorWidget();
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
              ? _buildEmptyFilteredOrders()
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return OrderHistoryCard(
                        order: order,
                        onTap: () => _viewOrderDetail(order),
                        onReorder: () => _reorder(order),
                        onRate: OrderService.canRateOrder(order) 
                            ? () => _rateOrder(order) 
                            : null,
                        onCancel: OrderService.canCancelOrder(order)
                            ? () => _cancelOrder(order)
                            : null,
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: screen.ScreenService.mediumSpacing),
          Text(
            'Đang tải đơn hàng...',
            style: TextStyle(
              fontSize: screen.ScreenService.mediumText,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screen.ScreenService.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: screen.ScreenService.mediumSpacing),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: screen.ScreenService.largeText,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: screen.ScreenService.smallSpacing),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: screen.ScreenService.mediumText,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screen.ScreenService.largeSpacing),
            ElevatedButton.icon(
              onPressed: _loadOrders,
              icon: Icon(Icons.refresh),
              label: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: screen.ScreenService.largeSpacing,
                  vertical: screen.ScreenService.mediumSpacing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilteredOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textLight,
          ),
          SizedBox(height: screen.ScreenService.mediumSpacing),
          Text(
            'Không có đơn hàng nào',
            style: TextStyle(
              fontSize: screen.ScreenService.mediumText,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: screen.ScreenService.smallSpacing),
          Text(
            'Không tìm thấy đơn hàng với trạng thái này',
            style: TextStyle(
              fontSize: screen.ScreenService.smallText,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _viewOrderDetail(OrderModel order) {
    Navigator.pushNamed(
      context,
      AppRoutes.orderDetail, // Sử dụng AppRoutes
      arguments: order,
    );
  }

  Future<void> _reorder(OrderModel order) async {
    try {
      // TODO: Implement reorder logic - add items to cart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đang thêm món vào giỏ hàng...'),
          backgroundColor: AppColors.primary,
        ),
      );
      
      // Navigate to cart after adding items
      Navigator.pushNamed(context, AppRoutes.cart);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể đặt lại đơn hàng'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _rateOrder(OrderModel order) async {
    // TODO: Show rating dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đánh giá đơn hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bạn cảm thấy đơn hàng này như thế nào?'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () async {
                    try {
                      await OrderService.rateOrder(
                        order.id,
                        (index + 1).toDouble(),
                        null,
                      );
                      Navigator.pop(context);
                      _loadOrders(); // Refresh orders
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đánh giá thành công!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Không thể đánh giá'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.star,
                    color: AppColors.warning,
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hủy đơn hàng'),
        content: Text('Bạn có chắc chắn muốn hủy đơn hàng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hủy đơn hàng'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await OrderService.cancelOrder(order.id, 'Hủy bởi người dùng');
        _loadOrders(); // Refresh orders
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã hủy đơn hàng thành công'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể hủy đơn hàng'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}