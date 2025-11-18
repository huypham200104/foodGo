class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  
  // Main routes
  static const String home = '/';
  static const String menu = '/menu';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String notification = '/notification';
  static const String search = '/search';
  
  // Product routes
  static const String productDetail = '/product-detail';
  
  // Order routes
  static const String checkout = '/checkout';
  static const String orderHistory = '/order-history';
  
  // Address routes
  static const String addressList = '/address-list';
  static const String addressManagement = '/address-management';
  
  // Error routes
  static const String notFound = '/not-found';
  
  // List of all routes for validation
  static const List<String> allRoutes = [
    login,
    register,
    home,
    menu,
    cart,
    profile,
    notification,
    search,
    productDetail,
    checkout,
    orderHistory,
    addressList,
    addressManagement,
    notFound,
  ];
}