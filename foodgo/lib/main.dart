import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'firebase_core/firebase_core.dart';  // 👈 XÓA dòng này (duplicate import)
import 'firebase_options.dart';
import 'pages/my_app.dart';
import 'upload_seed.dart' as upload_seed;

// Flag để bật/tắt upload seed data
const bool shouldUploadSeed = false;
const bool uploadAllData = false;
const bool clearDataBeforeUpload = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👈 Thêm error handling cho SystemChrome
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  } catch (e) {
    debugPrint('SystemChrome config warning: $e');
  }

  // 👈 Thêm error handling cho Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
    // Continue anyway - app might work without some Firebase features
  }

  // 👈 Seed data upload với better error handling
  if (shouldUploadSeed) {
    try {
      if (clearDataBeforeUpload) {
        debugPrint('🗑️  Bắt đầu xóa tất cả dữ liệu hiện có...');
        await upload_seed.clearAllData();
        debugPrint('✅ Đã xóa tất cả dữ liệu thành công!');
        
        await Future.delayed(const Duration(seconds: 1));
      }
      
      debugPrint('🔄 Bắt đầu upload seed data...');
      if (uploadAllData) {
        await upload_seed.uploadAllSeeds();
        debugPrint('✅ Đã upload tất cả seed data thành công!');
      } else {
        await upload_seed.uploadMenuItems();
        debugPrint('✅ Đã upload menu items thành công!');
      }
    } catch (e) {
      debugPrint('❌ Lỗi khi upload seed data: $e');
      // Don't block app launch due to seed data errors
    }
  }

  // 👈 Wrap runApp trong try-catch
  try {
    runApp(const MyApp());
  } catch (e) {
    debugPrint('❌ App launch error: $e');
    // Fallback app nếu MyApp fail
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('App failed to start'),
                const SizedBox(height: 8),
                Text('Error: $e'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}