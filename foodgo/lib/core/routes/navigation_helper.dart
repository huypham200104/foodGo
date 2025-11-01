import 'package:flutter/material.dart';
import 'app_routes.dart';

class NavigationHelper {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static BuildContext? get context => navigatorKey.currentContext;
  
  // Basic navigation methods
  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }
  
  static Future<T?> pushReplacementNamed<T, TO>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
    );
  }
  
  static Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }
  
  static void pop<T>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }
  
  static void popUntil(bool Function(Route<dynamic>) predicate) {
    return navigatorKey.currentState!.popUntil(predicate);
  }

  // Convenience methods for common navigation patterns
  static Future<void> goToLogin() {
    return pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }
  
  static Future<void> goToHome() {
    return pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }
  
  static Future<void> goToMenu([String? category]) {
    if (category != null) {
      return pushNamed(AppRoutes.menuCategory, arguments: category);
    }
    return pushNamed(AppRoutes.menu);
  }
  
  static Future<void> goToProductDetail(dynamic menuItem) {
    return pushNamed(AppRoutes.productDetail, arguments: menuItem);
  }
  
  static Future<void> goToCart() {
    return pushNamed(AppRoutes.cart);
  }
  
  static Future<void> goToProfile() {
    return pushNamed(AppRoutes.profile);
  }
  
  static Future<void> goToOrderDetail(String orderId) {
    return pushNamed(AppRoutes.orderDetail, arguments: orderId);
  }
  
  static Future<void> goToOrderTracking(String orderId) {
    return pushNamed(AppRoutes.orderTracking, arguments: orderId);
  }
  
  static Future<void> goToCheckout() {
    return pushNamed(AppRoutes.checkout);
  }
  
  static Future<void> goToSearch([String? query]) {
    return pushNamed(AppRoutes.search, arguments: query);
  }
}