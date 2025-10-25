import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../models/menu_item_model.dart';
import '../../../widgets/custom_login_form.dart';
import '../../../widgets/network_image_with_fallback.dart';
import '../../product/product_detail_page.dart';

class MenuItemCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const MenuItemCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (data['imageUrl'] ?? '').toString();
    final name = (data['name'] ?? '').toString();
    final description = (data['description'] ?? '').toString();
    final price = (data['price'] ?? 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: () {
          final menuItem = MenuItemModel.fromJson(data);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: menuItem),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FoodImage(
                imageUrl: imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  _formatVnd(price),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Consumer2<AuthProvider, CartProvider>(
            builder: (context, authProvider, cartProvider, child) {
              return IconButton(
                onPressed: () {
                  if (authProvider.isLoggedIn) {
                    // Add to cart
                    final menuItem = MenuItemModel.fromJson(data);
                    cartProvider.addToCart(
                      userId: authProvider.currentUser!.id,
                      item: menuItem,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                    );
                  } else {
                    // Show custom login form
                    _showCustomLoginForm(context);
                  }
                },
                icon: const Icon(Icons.add_shopping_cart_outlined),
              );
            },
          )
        ],
        ),
      ),
    );
  }

  String _formatVnd(dynamic value) {
    final intVal = value is num ? value.toInt() : int.tryParse(value.toString()) ?? 0;
    final s = intVal.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i - 1;
      buf.write(s[i]);
      final posFromEnd = s.length - i - 1;
      if (posFromEnd > 0 && posFromEnd % 3 == 0) buf.write('.');
    }
    final withDots = buf.toString();
    return '$withDots đ';
  }

  void _showCustomLoginForm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CustomLoginForm(
          title: 'Thêm vào giỏ hàng',
          message: 'Vui lòng đăng nhập để thêm món vào giỏ hàng',
          onSuccess: () {
            // After successful login, add item to cart
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final cartProvider = Provider.of<CartProvider>(context, listen: false);
            final menuItem = MenuItemModel.fromJson(data);
            cartProvider.addToCart(
              userId: authProvider.currentUser!.id,
              item: menuItem,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
            );
          },
        );
      },
    );
  }
}


