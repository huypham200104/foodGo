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
import '../../pages/orders/order_history_page.dart';
import '../../pages/error/not_found_page.dart';
import '../../providers/auth_provider.dart';
import '../../models/menu_item_model.dart';
import '../../pages/address/address_list_page.dart';
import '../../pages/address/address_management_page.dart';

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

      // Search route - 👈 Add search route
      case AppRoutes.search:
        final searchArgs = args as Map<String, dynamic>?;
        return _createRoute(
          Scaffold(
            appBar: AppBar(title: const Text('Tìm kiếm')),
            body: Center(
              child: Text('Search Page - Query: ${searchArgs?['query'] ?? ''}'),
            ),
          ),
        );

      // Product routes
      case AppRoutes.productDetail:
        if (args is MenuItemModel) {
          return _createRoute(ProductDetailPage(product: args));
        } else if (args is String) {
          // Handle product ID
          return _createRoute(
            Scaffold(
              appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
              body: Center(child: Text('Product ID: $args')),
            ),
          );
        }
        return _errorRoute('Product detail argument is required');

      // Order routes
      case AppRoutes.checkout:
        return _protectedRoute(const CheckoutPage());
      
      case AppRoutes.orderHistory:
        return _protectedRoute(const OrderHistoryPage());
      
      // Address Routes
      case AppRoutes.addressList:
        final addressArgs = args as Map<String, dynamic>?;
        return _protectedRoute(AddressListPage(
          selectMode: addressArgs?['selectMode'] ?? false,
          onAddressSelected: addressArgs?['onAddressSelected'],
        ));
        
      case AppRoutes.addressManagement:
        return _protectedRoute(const AddressManagementPage());

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