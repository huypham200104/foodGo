import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/menu_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/network_image_with_fallback.dart';
import '../../widgets/custom_login_form.dart';

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
  String? _selectedTopping;
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _totalPrice = widget.product.price;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  FoodImage(
                    imageUrl: widget.product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          
          // Product content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name and price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _formatVnd(_totalPrice),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Rating and description
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '4.5',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Đánh giá',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    Text(
                      widget.product.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Ingredients
                    if (widget.product.ingredients.isNotEmpty) ...[
                      Text(
                        'Nguyên liệu',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.product.ingredients.map((ingredient) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              ingredient,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Toppings
                    if (widget.product.toppings.isNotEmpty) ...[
                      Text(
                        'Tùy chọn',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.product.toppings.map((topping) {
                        final toppingName = topping['name'] ?? '';
                        final toppingPrice = (topping['price'] ?? 0).toDouble();
                        final isSelected = _selectedTopping == toppingName;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedTopping = toppingName;
                                _totalPrice = widget.product.price + toppingPrice;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected 
                                      ? AppColors.primary
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    toppingName,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected 
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  if (toppingPrice > 0)
                                    Text(
                                      '+${_formatVnd(toppingPrice)}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected 
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                    
                    // Quantity selector
                    Text(
                      'Số lượng',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: _quantity > 1 ? () {
                              setState(() {
                                _quantity--;
                                _updateTotalPrice();
                              });
                            } : null,
                            icon: const Icon(Icons.remove, color: AppColors.primary),
                          ),
                        ),
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            _quantity.toString(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _quantity++;
                                _updateTotalPrice();
                              });
                            },
                            icon: const Icon(Icons.add, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      
      // Bottom action bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Total price
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng cộng',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _formatVnd(_totalPrice * _quantity),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Add to cart button
            Consumer2<AuthProvider, CartProvider>(
              builder: (context, authProvider, cartProvider, child) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (authProvider.isLoggedIn) {
                        // Add to cart
                        cartProvider.addToCart(
                          userId: authProvider.currentUser!.id,
                          item: widget.product,
                          quantity: _quantity,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm $_quantity ${widget.product.name} vào giỏ hàng'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      } else {
                        // Show login form
                        _showCustomLoginForm(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_cart, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Thêm vào giỏ',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateTotalPrice() {
    double toppingPrice = 0;
    if (_selectedTopping != null) {
      final selectedTopping = widget.product.toppings.firstWhere(
        (topping) => topping['name'] == _selectedTopping,
        orElse: () => {'price': 0},
      );
      toppingPrice = (selectedTopping['price'] ?? 0).toDouble();
    }
    _totalPrice = widget.product.price + toppingPrice;
  }

  String _formatVnd(double value) {
    final intVal = value.toInt();
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
            cartProvider.addToCart(
              userId: authProvider.currentUser!.id,
              item: widget.product,
              quantity: _quantity,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã thêm $_quantity ${widget.product.name} vào giỏ hàng'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
        );
      },
    );
  }
}
