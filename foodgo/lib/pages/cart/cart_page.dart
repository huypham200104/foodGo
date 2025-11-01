import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/cart_item_model.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/network_image_with_fallback.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn) {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.loadCartItems(authProvider.currentUser?.id ?? '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        centerTitle: true,
      ),
      body: Consumer2<AuthProvider, CartProvider>(
        builder: (context, authProvider, cartProvider, child) {
          // Check if user is logged in
          if (!authProvider.isLoggedIn) {
            return _buildLoginRequired();
          }

          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartProvider.items.isEmpty) { // Sửa từ cartItems thành items
            return const _EmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: cartProvider.items.length, // Sửa từ cartItems thành items
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.items[index]; // Sửa từ cartItems thành items
                    return _CartItemTile(
                      cartItem: cartItem,
                      onQuantityChanged: (newQuantity) {
                        cartProvider.updateQuantity(cartItem, newQuantity);
                      },
                      onRemove: () {
                        cartProvider.removeFromCart(cartItem);
                      },
                    );
                  },
                ),
              ),
              _CartTotal(
                total: cartProvider.totalPrice,
                onCheckout: () {
                  // TODO: Implement checkout
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tính năng thanh toán đang được phát triển')),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Vui lòng đăng nhập để xem giỏ hàng',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.login); // Sử dụng routing system
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 96, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'Giỏ hàng trống',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm món để tiếp tục.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.menu);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xem thực đơn'),
          ),
        ],
      ),
    );
  }
}

class _CartTotal extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;
  const _CartTotal({required this.total, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                children: [
                  Text(
                    'Tổng cộng',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatVnd(total),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: onCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đặt hàng',
                    style: TextStyle(
                      color: Colors.white,
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

class _CartItemTile extends StatelessWidget {
  final CartItemModel cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Hình ảnh sản phẩm
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: NetworkImageWithFallback(
              imageUrl: cartItem.item.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatVnd(cartItem.item.price),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (cartItem.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ghi chú: ${cartItem.note}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Điều khiển số lượng
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: cartItem.quantity > 1 
                        ? () => onQuantityChanged(cartItem.quantity - 1)
                        : null,
                    iconSize: 20,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${cartItem.quantity}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => onQuantityChanged(cartItem.quantity + 1),
                    iconSize: 20,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Xóa',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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