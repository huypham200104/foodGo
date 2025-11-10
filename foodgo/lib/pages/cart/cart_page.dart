import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/cart_item_model.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../services/screen_service.dart' as screen;
import 'widgets/empty_cart_widget.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/cart_total_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  CartProvider? _cartProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.isLoggedIn) {
          _cartProvider = Provider.of<CartProvider>(context, listen: false);
          _cartProvider?.subscribe(authProvider.currentUser?.id ?? '');
        }
      }
    });
  }

  @override
  void dispose() {
    // Sử dụng reference đã lưu thay vì gọi Provider.of trong dispose
    _cartProvider?.unsubscribe();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screen.ScreenService.init(context);
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

          if (cartProvider.items.isEmpty) {
            return const EmptyCartWidget();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(screen.ScreenService.smallSpacing),
                  itemCount: cartProvider.items.length,
                  separatorBuilder: (_, __) => SizedBox(height: screen.ScreenService.smallSpacing),
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.items[index];
                    return CartItemTile(
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
              CartTotalWidget(
                total: cartProvider.totalPrice,
                onCheckout: () {
                  // Navigate to checkout page
                  Navigator.of(context).pushNamed(AppRoutes.checkout);
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
      child: Padding(
        padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined, 
              size: screen.ScreenService.largeSpacing * 2,
              color: Colors.grey,
            ),
            SizedBox(height: screen.ScreenService.mediumSpacing),
            Text(
              'Vui lòng đăng nhập để xem giỏ hàng',
              style: TextStyle(
                fontSize: screen.ScreenService.mediumText,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screen.ScreenService.mediumSpacing),
            SizedBox(
              width: double.infinity,
              height: screen.ScreenService.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
                  ),
                ),
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(fontSize: screen.ScreenService.mediumText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}