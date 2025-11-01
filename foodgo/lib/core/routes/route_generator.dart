import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_routes.dart';
import '../../pages/home/home_page.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/auth/signup_page.dart'; // Sửa từ register_page.dart thành signup_page.dart
// import '../../pages/auth/forgot_password_page.dart'; // Comment lại vì chưa có file này
import '../../pages/menu/menu_page.dart';
// import '../../pages/menu/menu_category_page.dart'; // Comment lại vì chưa có file này
import '../../pages/product/product_detail_page.dart'; // Sửa đường dẫn từ menu/product_detail_page.dart
// import '../../pages/menu/search_page.dart'; // Comment lại vì chưa có file này
import '../../pages/cart/cart_page.dart';
// import '../../pages/cart/checkout_page.dart'; // Comment lại vì chưa có file này
import '../../pages/profile/profile_page.dart';
// import '../../pages/profile/edit_profile_page.dart'; // Comment lại vì chưa có file này
// import '../../pages/profile/addresses_page.dart'; // Comment lại vì chưa có file này
// import '../../pages/profile/add_address_page.dart'; // Comment lại vì chưa có file này
// import '../../pages/profile/edit_address_page.dart'; // Comment lại vì chưa có file này
// import '../../pages/profile/settings_page.dart'; // Comment lại vì chưa có file này
// import '../../pages/profile/change_password_page.dart'; // Comment lại vì chưa có file này
// import '../../pages/order/order_history_page.dart'; // Comment lại vì chưa có file này
// import '../../pages/order/order_detail_page.dart'; // Comment lại vì chưa có file này
// import '../../pages/order/order_tracking_page.dart'; // Comment lại vì chưa có file này
import '../../pages/notification/notification_page.dart';
// import '../../pages/voucher/vouchers_page.dart'; // Comment lại vì chưa có file này
// import '../../pages/review/reviews_page.dart'; // Comment lại vì chưa có file này
// import '../../pages/review/write_review_page.dart'; // Comment lại vì chưa có file này
// import '../../pages/other/help_page.dart'; // Comment lại vì chưa có file này
// import '../../pages/other/about_page.dart'; // Comment lại vì chưa có file này
// import '../../pages/other/terms_of_service_page.dart'; // Comment lại vì chưa có file này
// import '../../pages/other/privacy_policy_page.dart'; // Comment lại vì chưa có file này
import '../../pages/error/not_found_page.dart';
import '../../providers/auth_provider.dart';
import '../../models/menu_item_model.dart';
// import '../../models/order_model.dart'; // Comment lại vì chưa dùng
// import '../../models/address_model.dart'; // Comment lại vì chưa dùng

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // Auth routes
      case AppRoutes.login:
        return _createRoute(const LoginPage());
      
      case AppRoutes.register:
        return _createRoute(const SignupPage()); // Sửa từ RegisterPage thành SignupPage
      
      // case AppRoutes.forgotPassword:
      //   return _createRoute(const ForgotPasswordPage());

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
      // case AppRoutes.menuCategory:
      //   if (args is String) {
      //     return _createRoute(MenuCategoryPage(category: args));
      //   }
      //   return _errorRoute('Menu category argument is required');
      
      case AppRoutes.productDetail:
        if (args is MenuItemModel) {
          return _createRoute(ProductDetailPage(product: args));
        }
        return _errorRoute('Product detail argument is required');
      
      // case AppRoutes.search:
      //   final searchQuery = args as String?;
      //   return _createRoute(SearchPage(initialQuery: searchQuery));

      // Order routes - Comment lại vì chưa có files
      // case AppRoutes.checkout:
      //   return _protectedRoute(const CheckoutPage());
      
      // case AppRoutes.orderHistory:
      //   return _protectedRoute(const OrderHistoryPage());
      
      // case AppRoutes.orderDetail:
      //   if (args is String) {
      //     return _protectedRoute(OrderDetailPage(orderId: args));
      //   }
      //   return _errorRoute('Order ID is required');
      
      // case AppRoutes.orderTracking:
      //   if (args is String) {
      //     return _protectedRoute(OrderTrackingPage(orderId: args));
      //   }
      //   return _errorRoute('Order ID is required');

      // Profile routes - Comment lại vì chưa có files
      // case AppRoutes.editProfile:
      //   return _protectedRoute(const EditProfilePage());
      
      // case AppRoutes.addresses:
      //   return _protectedRoute(const AddressesPage());
      
      // case AppRoutes.addAddress:
      //   return _protectedRoute(const AddAddressPage());
      
      // case AppRoutes.editAddress:
      //   if (args is AddressModel) {
      //     return _protectedRoute(EditAddressPage(address: args));
      //   }
      //   return _errorRoute('Address argument is required');
      
      // case AppRoutes.settings:
      //   return _protectedRoute(const SettingsPage());
      
      // case AppRoutes.changePassword:
      //   return _protectedRoute(const ChangePasswordPage());

      // Other routes - Comment lại vì chưa có files
      // case AppRoutes.vouchers:
      //   return _protectedRoute(const VouchersPage());
      
      // case AppRoutes.reviews:
      //   if (args is String) {
      //     return _createRoute(ReviewsPage(productId: args));
      //   }
      //   return _errorRoute('Product ID is required');
      
      // case AppRoutes.writeReview:
      //   if (args is String) {
      //     return _protectedRoute(WriteReviewPage(productId: args));
      //   }
      //   return _errorRoute('Product ID is required');
      
      // case AppRoutes.help:
      //   return _createRoute(const HelpPage());
      
      // case AppRoutes.about:
      //   return _createRoute(const AboutPage());
      
      // case AppRoutes.termsOfService:
      //   return _createRoute(const TermsOfServicePage());
      
      // case AppRoutes.privacyPolicy:
      //   return _createRoute(const PrivacyPolicyPage());

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