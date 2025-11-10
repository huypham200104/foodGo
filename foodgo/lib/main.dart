import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/routes/app_router.dart';    // 👈 Import AppRouter
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/my_app.dart';
import 'upload_seed.dart' as upload_seed;

// Flag để bật/tắt upload seed data
const bool shouldUploadSeed = false; // Đặt false sau khi upload xong
const bool uploadAllData = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Đảm bảo hỗ trợ input method cho tiếng Việt
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Upload seed data nếu cần
  if (shouldUploadSeed) {
    try {
      print('🔄 Bắt đầu upload seed data...');
      if (uploadAllData) {
        await upload_seed.uploadAllSeeds();
        print('✅ Đã upload tất cả seed data thành công!');
      } else {
        await upload_seed.uploadMenuItems();
        print('✅ Đã upload menu items thành công!');
      }
    } catch (e) {
      print('❌ Lỗi khi upload seed data: $e');
    }
  }

  // Khởi chạy app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodGo',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,  // 👈 Sử dụng AppRouter
      debugShowCheckedModeBanner: false,
    );
  }
}

