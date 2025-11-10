import 'package:flutter/material.dart';
import '../../pages/address/address_list_page.dart';
import '../../pages/address/address_management_page.dart';
import '../../pages/checkout/checkout_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/auth/register_page.dart';
import '../../pages/cart/cart_page.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/menu/menu_page.dart';
import '../../pages/search/search_page.dart';
import '../../pages/notification/notification_page.dart';
import '../../pages/product/product_detail_page.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (context) => const LoginPage(),
        );
        
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (context) => const RegisterPage(),
        );
      
      // Main Navigation Routes
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
        );
        
      case AppRoutes.menu:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => MenuPage(
            filter: args?['filter'],
            category: args?['category'],
          ),
        );
        
      case AppRoutes.cart:
        return MaterialPageRoute(
          builder: (context) => const CartPage(),
        );
        
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        );
        
      case AppRoutes.notification:
        return MaterialPageRoute(
          builder: (context) => const NotificationPage(),
        );
        
      case AppRoutes.search:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => SearchPage(
            query: args?['query'],
          ),
        );
        
      // Address Routes - 👈 Đây là phần quan trọng
      case AppRoutes.addressList:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => AddressListPage(
            selectMode: args?['selectMode'] ?? false,
            onAddressSelected: args?['onAddressSelected'],
          ),
        );
        
      case AppRoutes.addressManagement:
        return MaterialPageRoute(
          builder: (context) => const AddressManagementPage(),
        );
        
      // Checkout Routes
      case AppRoutes.checkout:
        return MaterialPageRoute(
          builder: (context) => const CheckoutPage(),
        );
        
      // Product Routes
      case AppRoutes.productDetail:
        final productId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => ProductDetailPage(
            productId: productId ?? '',
          ),
        );
        
      // Error Routes
      case AppRoutes.notFound:
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Không tìm thấy trang'),
              centerTitle: true,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '404 - Không tìm thấy trang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Trang bạn tìm kiếm không tồn tại',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}