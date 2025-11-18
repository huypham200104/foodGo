import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/menu_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/menu_service.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../services/screen_service.dart';
import 'widgets/product_image_header.dart';
import 'widgets/product_quantity_section.dart';
import 'widgets/product_add_to_cart_bar.dart';
import 'widgets/product_details_section.dart';

class ProductDetailPage extends StatefulWidget {
  final String? productId;
  final MenuItemModel? product;

  const ProductDetailPage({
    super.key,
    this.productId,
    this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  String? _selectedSize;
  List<ToppingOption> _selectedToppings = []; // 👈 Sửa kiểu dữ liệu
  final TextEditingController _noteController = TextEditingController();

  // State cho loading data
  MenuItemModel? _product;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeProduct();
  }

  Future<void> _initializeProduct() async {
    if (widget.product != null) {
      // Nếu đã có product data
      setState(() {
        _product = widget.product;
      });
      return;
    }

    if (widget.productId != null) {
      // Load product từ productId
      await _loadProductById(widget.productId!);
    } else {
      // Thử lấy từ route arguments
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is String) {
          _loadProductById(args);
        } else if (args is MenuItemModel) {
          setState(() {
            _product = args;
          });
        } else {
          setState(() {
            _error = 'Không tìm thấy thông tin sản phẩm';
          });
        }
      });
    }
  }

  Future<void> _loadProductById(String productId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('Loading product with ID: $productId');

      // Thử load từ cache trước
      final product = await MenuService.getProductById(productId);

      if (product != null) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Không tìm thấy sản phẩm';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading product: $e');
      setState(() {
        _error = 'Lỗi khi tải sản phẩm: $e';
        _isLoading = false;
      });
    }
  }

  // Helper methods để lấy sizes và toppings an toàn
  List<String> get _productSizes {
    try {
      return _product?.sizes ?? [];
    } catch (e) {
      debugPrint('Error getting sizes: $e');
      return <String>[];
    }
  }

  List<String> get _productToppings {
    try {
      return _product?.toppings ?? [];
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

  void _onToppingsChanged(List<ToppingOption> toppings) { // 👈 Sửa kiểu callback
    setState(() {
      _selectedToppings = toppings;
    });
  }

  Future<void> _handleAddToCart() async {
    if (_product == null) return;

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
        item: _product!,
        quantity: _quantity,
        selectedToppings: _selectedToppings.map((t) => t.toJson()).toList(),
        note: _noteController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm ${_product!.name} vào giỏ hàng'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.success,
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
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenService.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_product == null) {
      return _buildNotFoundState();
    }

    return _buildProductDetail();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: ScreenService.mediumSpacing),
          Text(
            'Đang tải thông tin sản phẩm...',
            style: TextStyle(
              fontSize: ScreenService.mediumText,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenService.mediumSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: ScreenService.mediumSpacing),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: ScreenService.largeText,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: ScreenService.smallSpacing),
            Text(
              _error!,
              style: TextStyle(
                fontSize: ScreenService.smallText,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ScreenService.mediumSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Quay lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textSecondary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (widget.productId != null) {
                      _loadProductById(widget.productId!);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenService.mediumSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: ScreenService.mediumSpacing),
            Text(
              'Không tìm thấy sản phẩm',
              style: TextStyle(
                fontSize: ScreenService.largeText,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: ScreenService.smallSpacing),
            Text(
              'Sản phẩm bạn đang tìm kiếm không tồn tại hoặc đã bị xóa',
              style: TextStyle(
                fontSize: ScreenService.smallText,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ScreenService.mediumSpacing),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Quay lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetail() {
    return Column(
      children: [
        // Main content
        Expanded(
          child: CustomScrollView(
            slivers: [
              // App Bar với hình ảnh
              ProductImageHeader(
                imageUrl: _product!.imageUrl,
              ),

              // Nội dung chi tiết
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product details section
                      ProductDetailsSection(
                        product: _product!,
                        quantity: _quantity,
                        selectedToppings: _selectedToppings,
                        onToppingsChanged: _onToppingsChanged,
                      ),

                      SizedBox(height: ScreenService.mediumSpacing),

                      // Chọn số lượng
                      ProductQuantitySection(
                        quantity: _quantity,
                        onQuantityChanged: _onQuantityChanged,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom bar
        ProductAddToCartBar(
          product: _product!,
          quantity: _quantity,
          selectedToppings: _selectedToppings.map((t) => {
            'name': t.name,
            'price': t.price,
          }).toList(), // 👈 Chuyển đổi sang Map để tương thích
          // Require selection if product has topping options
          canAdd: _product!.effectiveToppingOptions.isEmpty || _selectedToppings.isNotEmpty,
          onAddToCart: _handleAddToCart,
        ),
      ],
    );
  }
}
