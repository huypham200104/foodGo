import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/menu_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../core/routes/app_routes.dart';
import 'widgets/product_image_header.dart';
import 'widgets/product_info_section.dart';
import 'widgets/product_options_section.dart';
import 'widgets/product_note_section.dart';
import 'widgets/product_quantity_section.dart';
import 'widgets/product_add_to_cart_bar.dart';

class ProductDetailPage extends StatefulWidget {
  final MenuItemModel product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  String? _selectedSize;
  List<Map<String, dynamic>> _selectedToppings = [];
  final TextEditingController _noteController = TextEditingController();

  // Helper methods để lấy sizes và toppings an toàn
  List<String> get _productSizes {
    try {
      return widget.product.sizes;
    } catch (e) {
      debugPrint('Error getting sizes: $e');
      return <String>[];
    }
  }

  List<String> get _productToppings {
    try {
      return widget.product.toppings;
    } catch (e) {
      debugPrint('Error getting toppings: $e');
      return <String>[];
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onQuantityChanged(int newQuantity) {
    setState(() {
      _quantity = newQuantity;
    });
  }

  void _onSizeSelected(String? size) {
    setState(() {
      _selectedSize = size;
    });
  }

  void _onToppingsChanged(List<Map<String, dynamic>> toppings) {
    setState(() {
      _selectedToppings = toppings;
    });
  }

  Future<void> _handleAddToCart() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (!authProvider.isLoggedIn) {
      Navigator.of(context).pushNamed(AppRoutes.login);
      return;
    }

    try {
      // Sử dụng uid
      final userId = authProvider.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        throw Exception('Không thể xác định người dùng');
      }

      await cartProvider.addToCart(
        userId: userId,
        item: widget.product,
        quantity: _quantity,
        selectedToppings: List<Map<String, dynamic>>.from(_selectedToppings),
        note: _noteController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm ${widget.product.name} vào giỏ hàng'),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar với hình ảnh
          ProductImageHeader(
            imageUrl: widget.product.imageUrl,
          ),

          // Nội dung chi tiết
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin sản phẩm
                  ProductInfoSection(
                    product: widget.product,
                  ),
                  const SizedBox(height: 24),

                  // Chọn size và toppings
                  ProductOptionsSection(
                    sizes: _productSizes,
                    toppings: _productToppings.cast<dynamic>(), // Cast List<String> to List<dynamic>
                    selectedSize: _selectedSize,
                    selectedToppings: _selectedToppings,
                    onSizeChanged: _onSizeSelected,
                    onToppingsChanged: _onToppingsChanged,
                  ),

                  // Ghi chú
                  ProductNoteSection(
                    controller: _noteController,
                  ),
                  const SizedBox(height: 24),

                  // Chọn số lượng
                  ProductQuantitySection(
                    quantity: _quantity,
                    onQuantityChanged: _onQuantityChanged,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom bar với nút thêm vào giỏ hàng
      bottomNavigationBar: ProductAddToCartBar(
        product: widget.product,
        quantity: _quantity,
        onAddToCart: _handleAddToCart,
      ),
    );
  }
}
