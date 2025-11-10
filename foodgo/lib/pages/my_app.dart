import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';
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
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'FoodGo',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            locale: localeProvider.locale,
            initialRoute: AppRoutes.home,
            onGenerateRoute: RouteGenerator.generateRoute,
            onUnknownRoute: RouteGenerator.generateRoute,
            builder: (context, child) {
              // Initialize ScreenService globally
              ScreenService.init(context);
              return child!;
            },
          );
        },
      ),
    );
  }
}
