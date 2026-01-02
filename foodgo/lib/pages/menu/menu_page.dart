import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constans/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../services/screen_service.dart';
import '../../services/menu_service.dart';
import '../../models/menu_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import 'widgets/menu_item_card.dart';
import 'widgets/menu_category_tabs.dart';

class MenuPage extends StatefulWidget {
  final String? initialCategory; // 👈 Đảm bảo tên parameter này đúng
  final String? filter;
  
  const MenuPage({
    super.key,
    this.initialCategory, // 👈 Đảm bảo tên parameter này đúng
    this.filter,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';
  List<MenuItemModel> _menuItems = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  static const List<Map<String, dynamic>> kDefaultCategories = [
    {'id': 'all', 'name': 'Tất cả', 'icon': Icons.restaurant},
    {'id': 'burger', 'name': 'Burger', 'icon': Icons.lunch_dining},
    {'id': 'chicken', 'name': 'Gà Rán', 'icon': Icons.set_meal},
    {'id': 'pizza', 'name': 'Pizza', 'icon': Icons.local_pizza},
    {'id': 'drink', 'name': 'Đồ Uống', 'icon': Icons.local_drink},
    {'id': 'dessert', 'name': 'Tráng Miệng', 'icon': Icons.cake},
    {'id': 'combo', 'name': 'Combo', 'icon': Icons.redeem},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'all';
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScreenService.init(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load categories - now with guaranteed icons
      final categories = await MenuService.getCategories();
      _categories = categories.isNotEmpty ? categories : kDefaultCategories;
      
      // Ensure all categories have icons
      _categories = _categories.map((category) {
        if (category['icon'] == null) {
          return {
            ...category,
            'icon': AppIcons.getIconData(category['id'] ?? ''),
          };
        }
        return category;
      }).toList();
      
      // Setup tab controller
      _tabController = TabController(
        length: _categories.length,
        vsync: this,
        initialIndex: _categories.indexWhere((c) => c['id'] == _selectedCategory).clamp(0, _categories.length - 1),
      );
      
      // Load menu items based on filter or category
      if (widget.filter == 'new') {
        _menuItems = await MenuService.getNewProducts();
      } else if (widget.filter == 'bestseller') {
        _menuItems = await MenuService.getBestsellerProducts();
      } else {
        await _loadMenuItems(_selectedCategory);
      }
      
    } catch (e) {
      print('Error loading menu data: $e');
      _categories = kDefaultCategories;
      _tabController = TabController(length: _categories.length, vsync: this);
      _menuItems = [];
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadMenuItems(String categoryId) async {
    try {
      if (categoryId == 'all') {
        _menuItems = await MenuService.getAllMenuItems();
      } else {
        _menuItems = await MenuService.getMenuItemsByCategory(categoryId);
      }
    } catch (e) {
      print('Error loading menu items: $e');
      _menuItems = [];
    }
  }

  void _onCategoryChanged(int index) {
    final categoryId = _categories[index]['id'] as String;
    if (categoryId != _selectedCategory) {
      setState(() {
        _selectedCategory = categoryId;
        _isLoading = true;
      });
      _loadMenuItems(categoryId).then((_) {
        setState(() => _isLoading = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          _getPageTitle(),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: ScreenService.largeText,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category tabs
          Container(
            color: AppColors.surface,
            child: MenuCategoryTabs(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
            ),
          ),
          
          // Menu items
          Expanded(
            child: _isLoading 
              ? _buildLoadingState()
              : _menuItems.isEmpty 
                ? _buildEmptyState()
                : _buildMenuList(),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    if (widget.filter == 'new') return 'Sản phẩm mới';
    if (widget.filter == 'bestseller') return 'Sản phẩm bán chạy';
    return 'Thực đơn';
  }

  Widget _buildLoadingState() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: ScreenService.mediumSpacing),
            Text(
              'Đang tải thực đơn...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: ScreenService.mediumText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.all(ScreenService.mediumSpacing),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: ScreenService.largeSpacing * 3,
              color: AppColors.textLight,
            ),
            SizedBox(height: ScreenService.mediumSpacing),
            Text(
              'Không có món ăn nào',
              style: TextStyle(
                fontSize: ScreenService.largeText,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: ScreenService.smallSpacing),
            Text(
              'Thử chọn danh mục khác hoặc quay lại sau',
              style: TextStyle(
                fontSize: ScreenService.mediumText,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return Container(
      color: AppColors.background,
      child: RefreshIndicator(
        onRefresh: () => _loadMenuItems(_selectedCategory),
        color: AppColors.primary,
        child: ListView.builder(
          padding: EdgeInsets.all(ScreenService.smallSpacing),
          itemCount: _menuItems.length,
          itemBuilder: (context, index) {
            final menuItem = _menuItems[index];
            return MenuItemCard(
              menuItem: menuItem,
              onTap: () {
                // Navigate to product detail
                Navigator.of(context).pushNamed(
                  '/product-detail',
                  arguments: menuItem,
                );
              },
              onAddToCart: () {
                // Nếu món có topping options, mở trang chi tiết để chọn
                if (menuItem.effectiveToppingOptions.isNotEmpty) {
                  Navigator.of(context).pushNamed(
                    '/product-detail',
                    arguments: menuItem,
                  );
                } else {
                  // Nếu không có topping, thêm trực tiếp vào giỏ hàng
                  _addToCart(menuItem);
                }
              },
            );
          },
        ),
      ),
    );
  }

  void _addToCart(MenuItemModel menuItem) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng đăng nhập để thêm vào giỏ hàng'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
          ),
        ),
      );
      Navigator.of(context).pushNamed('/login');
      return;
    }

    final userId = authProvider.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart(
      userId: userId,
      item: menuItem,
      quantity: 1,
      selectedToppings: const [],
      note: '',
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${menuItem.name} đã được thêm vào giỏ hàng'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
          ),
        ),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenService.smallSpacing),
          ),
        ),
      );
    });
  }
}



