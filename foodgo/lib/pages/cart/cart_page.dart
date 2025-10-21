import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/cart_item_model.dart';
import '../../pages/auth/login_page.dart';

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
        cartProvider.loadCartItems(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: Consumer2<AuthProvider, CartProvider>(
        builder: (context, authProvider, cartProvider, child) {
          // Check if user is logged in
          if (!authProvider.isLoggedIn) {
            return _buildLoginRequired();
          }

          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartProvider.cartItems.isEmpty) {
            return const _EmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: cartProvider.cartItems.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.cartItems[index];
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
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
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
          const Icon(Icons.shopping_bag_outlined, size: 96),
          const SizedBox(height: 12),
          Text('Giỏ hàng trống', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Hãy thêm món để tiếp tục.', style: Theme.of(context).textTheme.bodyMedium),
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, -2)),
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
                  Text('Tổng cộng', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(_formatVnd(total), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: onCheckout,
                child: const Text('Đặt hàng'),
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
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          cartItem.item.imageUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        cartItem.item.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(_formatVnd(cartItem.item.price)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => onQuantityChanged(cartItem.quantity - 1),
          ),
          Text('${cartItem.quantity}'),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onQuantityChanged(cartItem.quantity + 1),
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