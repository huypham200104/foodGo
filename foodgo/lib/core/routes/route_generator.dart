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
import '../../pages/notification/notification_settings_page.dart';
import '../../pages/orders/order_history_page.dart';
import '../../pages/error/not_found_page.dart';
import '../../providers/auth_provider.dart';
import '../../models/menu_item_model.dart';
import '../../pages/address/address_list_page.dart';
import '../../pages/address/address_management_page.dart';
import '../../pages/rewards/rewards_list_page.dart';
import '../../pages/vouchers/vouchers_list_page.dart';
import '../../pages/favorites/favorite_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    debugPrint('🚦 Navigating to: ${settings.name} with args: $args');

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
        final menuArgs = args as Map<String, dynamic>?;
        return _createRoute(MenuPage(
          filter: menuArgs?['filter'],
          initialCategory: menuArgs?['categoryId'],
        ));
      
      case AppRoutes.cart:
        return _protectedRoute(const CartPage());
      
      case AppRoutes.profile:
        return _protectedRoute(const ProfilePage());
      
      case AppRoutes.notification:
        return _createRoute(const NotificationPage());
      
      case AppRoutes.notificationSettings:
        return _protectedRoute(const NotificationSettingsPage());
      
      case AppRoutes.rewards:
        return _protectedRoute(const RewardsListPage());

      case AppRoutes.vouchers:
        return _protectedRoute(const VouchersListPage());

      case AppRoutes.favorites:
        return _protectedRoute(const FavoritePage());

      // Search route
      case AppRoutes.search:
        final searchArgs = args as Map<String, dynamic>?;
        return _createRoute(_SearchPage(
          initialQuery: searchArgs?['query'],
        ));

      // Product routes
      case AppRoutes.productDetail:
        if (args is MenuItemModel) {
          // Truyền trực tiếp MenuItemModel
          return _createRoute(ProductDetailPage(product: args));
        } else if (args is String) {
          // Truyền productId
          return _createRoute(ProductDetailPage(productId: args));
        } else if (args is Map<String, dynamic>) {
          // Truyền arguments map
          return _createRoute(ProductDetailPage(
            productId: args['productId'],
            product: args['product'],
          ));
        }
        // Fallback: không có arguments
        return _errorRoute('Product detail: Missing product information');

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

      // Error route
      case AppRoutes.notFound:
        final message = args is String ? args : 'Page not found';
        return _createRoute(NotFoundPage(message: message));

      // Default case
      default:
        debugPrint('❌ Unknown route: ${settings.name}');
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide transition from right to left
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
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
              return Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

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
        return FadeTransition(
          opacity: animation, 
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

class _SearchPage extends StatelessWidget {
  final String? initialQuery;

  const _SearchPage({
    this.initialQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search input
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: initialQuery ?? 'Tìm kiếm món ăn...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                // TODO: Implement search functionality
                debugPrint('Search query: $value');
              },
            ),
            
            const SizedBox(height: 20),
            
            // Placeholder content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tìm kiếm món ăn yêu thích',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      initialQuery != null 
                          ? 'Tìm kiếm: "$initialQuery"' 
                          : 'Nhập từ khóa để bắt đầu tìm kiếm',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
