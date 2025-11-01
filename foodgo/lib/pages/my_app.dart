import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
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
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'FoodGo',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.theme,
            locale: localeProvider.locale,
            // Sử dụng routing system thay vì home
            initialRoute: AppRoutes.home, // hoặc AppRoutes.login nếu cần authentication
            onGenerateRoute: RouteGenerator.generateRoute,
            // Xử lý route không tìm thấy
            onUnknownRoute: RouteGenerator.generateRoute,
          );
        },
      ),
    );
  }
}
