import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/notification_settings_provider.dart';
import '../services/screen_service.dart';
import '../core/routes/route_generator.dart';
import '../core/routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationSettingsProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'FoodGo - Đặt đồ ăn online',
            debugShowCheckedModeBanner: false,
            
            // Theme
            theme: themeProvider.themeData,
            locale: localeProvider.locale,
            
            // Routing - 👈 Sử dụng RouteGenerator hoàn toàn
            initialRoute: AppRoutes.home,
            onGenerateRoute: RouteGenerator.generateRoute,
            onUnknownRoute: (settings) => RouteGenerator.generateRoute(
              RouteSettings(
                name: AppRoutes.notFound,
                arguments: 'Unknown route: ${settings.name}',
              ),
            ),
            
            // Global builder
            builder: (context, child) {
              // Initialize ScreenService globally
              ScreenService.init(context);
              
              // Handle potential navigation errors
              if (child == null) {
                debugPrint('❌ Child is null in MaterialApp builder');
                return const Scaffold(
                  body: Center(
                    child: Text('App initialization error'),
                  ),
                );
              }
              
              return child;
            },
            
            // Navigation observers for debugging
            navigatorObservers: [
              _AppNavigatorObserver(),
            ],
          );
        },
      ),
    );
  }
}

// 👈 Navigator Observer để debug navigation
class _AppNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    debugPrint('🚦 Pushed: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    debugPrint('🚦 Popped: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    debugPrint('🚦 Replaced: ${oldRoute?.settings.name} → ${newRoute?.settings.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    debugPrint('🚦 Removed: ${route.settings.name}');
  }
}

