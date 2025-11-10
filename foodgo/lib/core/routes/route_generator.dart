import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_routes.dart';
import '../../pages/home/home_page.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/auth/signup_page.dart';
import '../../pages/menu/menu_page.dart';
import '../../pages/product/product_detail_page.dart';
import '../../pages/cart/cart_page.dart';
import '../../pages/checkout/checkout_page.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/notification/notification_page.dart';
import '../../pages/orders/order_history_page.dart'; // Thêm import này
import '../../pages/error/not_found_page.dart';
import '../../providers/auth_provider.dart';
import '../../models/menu_item_model.dart';
import '../../pages/address/address_list_page.dart'; // Thêm import

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // Auth routes
      case AppRoutes.login:
        return _createRoute(const LoginPage());
      
      case AppRoutes.register:
        return _createRoute(const SignupPage());

      // Main navigation routes
      case AppRoutes.home:
        return _createRoute(const HomePage());
      
      case AppRoutes.menu:
        return _createRoute(const MenuPage());
      
      case AppRoutes.cart:
        return _protectedRoute(const CartPage());
      
      case AppRoutes.profile:
        return _protectedRoute(const ProfilePage());
      
      case AppRoutes.notification:
        return _createRoute(const NotificationPage());

      // Menu & Product routes
      case AppRoutes.productDetail:
        if (args is MenuItemModel) {
          return _createRoute(ProductDetailPage(product: args));
        }
        return _errorRoute('Product detail argument is required');

      // Order routes
      case AppRoutes.checkout:
        return _protectedRoute(const CheckoutPage());
      
      case AppRoutes.orderHistory: // Thêm route này
        return _protectedRoute(const OrderHistoryPage());
      
      // Temporary routes cho các trang chưa có (để tránh crash)
      case AppRoutes.addresses:
        return _protectedRoute(const AddressListPage());
      
      case AppRoutes.paymentMethods:
        return _temporaryRoute('Phương thức thanh toán', 'Tính năng đang phát triển');
      
      case AppRoutes.favorites:
        return _temporaryRoute('Yêu thích', 'Tính năng đang phát triển');
      
      case AppRoutes.notifications:
        return _temporaryRoute('Cài đặt thông báo', 'Tính năng đang phát triển');
      
      case AppRoutes.help:
        return _temporaryRoute('Trợ giúp & Hỗ trợ', 'Tính năng đang phát triển');
      
      case AppRoutes.about:
        return _temporaryRoute('Về ứng dụng', 'Thông tin về FoodGo App');
      
      case AppRoutes.orderDetail:
        return _temporaryRoute('Chi tiết đơn hàng', 'Tính năng đang phát triển');

      // Default case
      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder _protectedRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoggedIn) {
              return page;
            } else {
              // Redirect to login if not authenticated
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              });
              return const SizedBox.shrink();
            }
          },
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Route tạm thời cho các trang chưa implement
  static PageRouteBuilder _temporaryRoute(String title, String message) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.construction,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Quay lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static PageRouteBuilder _errorRoute(String message) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => NotFoundPage(
        message: message,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}