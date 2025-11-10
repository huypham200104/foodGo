class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  
  // Address routes
  static const String addressList = '/address-list';         // 👈 AddressListPage
  static const String addressManagement = '/address-management';  // 👈 AddressManagementPage
  
  // Main navigation routes
  static const String home = '/';
  static const String menu = '/menu';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String notification = '/notification';
  
  // Menu & Product routes
  static const String menuCategory = '/menu-category';
  static const String productDetail = '/product-detail';
  static const String search = '/search';
  
  // Order routes
  static const String checkout = '/checkout';
  static const String orderHistory = '/order-history';
  static const String orderDetail = '/order-detail';
  static const String orderTracking = '/order-tracking';
  
  // Profile routes
  static const String editProfile = '/edit-profile';
  static const String addresses = '/addresses';
  static const String addAddress = '/add-address';
  static const String editAddress = '/edit-address';
  static const String settings = '/settings';
  static const String changePassword = '/change-password';
  static const String paymentMethods = '/payment-methods';
  static const String favorites = '/favorites';
  static const String notifications = '/notifications';
  
  // Other routes
  static const String vouchers = '/vouchers';
  static const String reviews = '/reviews';
  static const String writeReview = '/write-review';
  static const String help = '/help';
  static const String about = '/about';
  static const String termsOfService = '/terms-of-service';
  static const String privacyPolicy = '/privacy-policy';
  
  // Error routes
  static const String notFound = '/404';
  
  /// Get all route names for validation
  static List<String> get allRoutes => [
    login,
    register,
    addressList,
    addressManagement,
    home,
    menu,
    cart,
    profile,
    notification,
    menuCategory,
    productDetail,
    search,
    checkout,
    orderHistory,
    orderDetail,
    orderTracking,
    editProfile,
    addresses,
    addAddress,
    editAddress,
    settings,
    changePassword,
    paymentMethods,
    favorites,
    notifications,
    vouchers,
    reviews,
    writeReview,
    help,
    about,
    termsOfService,
    privacyPolicy,
    notFound,
  ];
}