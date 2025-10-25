import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import 'widgets/top_bar.dart';
import 'widgets/search_field.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/top_search_chips.dart';
import 'widgets/section_header.dart';
import 'widgets/horizontal_card_list.dart';
import '../menu/menu_page.dart';
import '../notification/notification_page.dart';
import '../cart/cart_page.dart';
import '../profile/profile_page.dart';
import '../../widgets/custom_login_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentBanner = 0;
  int _currentTab = 0;

  final List<String> _bannerImageUrls = const [
    'https://res.cloudinary.com/dbw8mvdqo/image/upload/v1760339581/voucher_donDauTien.jpg',
    'https://res.cloudinary.com/dbw8mvdqo/image/upload/v1760339581/voucher_freeship.jpg',
    'https://res.cloudinary.com/dbw8mvdqo/image/upload/v1760339581/voucher_t3HangTuan.jpg',
  ];

  final List<Map<String, dynamic>> _newProducts = const [
    {
      'imageUrl': 'https://res.cloudinary.com/dbw8mvdqo/image/upload/v1760339581/pizza_HaiSan.png',
      'name': 'Pizza Hải Sản',
      'price': '299.000đ'
    },
    {
      'imageUrl': 'https://res.cloudinary.com/dbw8mvdqo/image/upload/v1760339581/pizza_ThapCam.png',
      'name': 'Pizza Thập Cẩm',
      'price': '279.000đ'
    },
    {
      'imageUrl': 'https://res.cloudinary.com/dbw8mvdqo/image/upload/v1760339581/burgerBo.png',
      'name': 'Burger Bò',
      'price': '89.000đ'
    },
    {
      'imageUrl': 'https://res.cloudinary.com/dbw8mvdqo/image/upload/v1760339581/burgerGa.png',
      'name': 'Burger Gà',
      'price': '79.000đ'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    return Scaffold(
      appBar: TopBar(onToggleTheme: themeProvider.toggleTheme),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const SearchField(),
              const SizedBox(height: 12),
              BannerCarousel(
                imageUrls: _bannerImageUrls,
                currentIndex: _currentBanner,
                onPageChanged: (i) => setState(() => _currentBanner = i),
              ),
              const SizedBox(height: 8),
              Text('Top tìm kiếm', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const TopSearchChips(),
              const SizedBox(height: 12),
              const SectionHeader(title: 'Sản phẩm mới'),
              const SizedBox(height: 8),
              HorizontalCardList(products: _newProducts),
              const SizedBox(height: 12),
              const SectionHeader(title: 'Sản phẩm bán chạy'),
              const SizedBox(height: 8),
              HorizontalCardList(products: _newProducts),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return BottomNavigationBar(
            currentIndex: _currentTab,
            onTap: (i) {
              setState(() => _currentTab = i);
              if (i == 1) {
                // Notifications
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationPage()));
              } else if (i == 2) {
                // Cart - Check authentication
                if (authProvider.isLoggedIn) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartPage()));
                } else {
                  _showCustomLoginForm(context, 'Giỏ hàng', 'Vui lòng đăng nhập để xem giỏ hàng của bạn');
                }
              } else if (i == 3) {
                // Profile - Check authentication
                if (authProvider.isLoggedIn) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
                } else {
                  _showCustomLoginForm(context, 'Tài khoản', 'Vui lòng đăng nhập để quản lý tài khoản của bạn');
                }
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Thông báo'),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_checkout_rounded), label: 'Giỏ hàng'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Tài khoản'),
            ],
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 12,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'menu_fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MenuPage()),
          );
        },
        child: const Icon(Icons.restaurant_menu_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showCustomLoginForm(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CustomLoginForm(
          title: title,
          message: message,
          onSuccess: () {
            // Navigate to the intended page after successful login
            if (title == 'Giỏ hàng') {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartPage()));
            } else if (title == 'Tài khoản') {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            }
          },
        );
      },
    );
  }
}