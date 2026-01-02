import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'pages/my_app.dart';
import 'upload_seed.dart' as upload_seed;

// ⚠️ QUAN TRỌNG: Đặt shouldUploadSeed = true để upload dữ liệu lên Firebase
// Sau khi upload xong, nhớ đặt lại = false để tránh upload lại mỗi lần chạy app
const bool shouldUploadSeed = false;

// Đặt uploadAllData = true để upload TẤT CẢ dữ liệu (restaurants, menu_items, vouchers, rewards, notifications)
// Đặt = false để chỉ upload menu_items
const bool uploadAllData = false;

// Đặt uploadNotificationsOnly = true để chỉ upload notifications
const bool uploadNotificationsOnly = false;

// ⚠️ Đặt clearOldRewards = true để XÓA dữ liệu rewards cũ trước khi upload lại
// Cần thiết khi bạn đã upload rewards với document IDs sai (random IDs thay vì userId)
const bool clearOldRewards = false;

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
    debugPrint('🔗 Configured Firebase projectId: ${DefaultFirebaseOptions.currentPlatform.projectId}');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
    // Continue anyway - app might work without some Firebase features
  }

  // 👈 Seed data upload - CHỈ UPDATE/THÊM MỚI, KHÔNG XÓA DỮ LIỆU CŨ
  print('main(): SHOULD_UPLOAD_SEED=$shouldUploadSeed UPLOAD_ALL_DATA=$uploadAllData CLEAR_OLD_REWARDS=$clearOldRewards');
  if (shouldUploadSeed) {
    try {
      debugPrint('🔄 Bắt đầu upload/update seed data...');
      
      // Small delay to let Firestore settle
      await Future.delayed(const Duration(milliseconds: 500));

      // Xóa rewards cũ nếu cần (để fix document ID issue)
      if (clearOldRewards) {
        debugPrint('🗑️  Đang xóa rewards cũ để upload lại với document IDs đúng...');
        await upload_seed.clearSpecificData(['rewards']);
        debugPrint('✅ Đã xóa rewards cũ!');
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (uploadAllData) {
        await upload_seed.uploadAllSeeds();
        debugPrint('✅ Đã upload/update tất cả seed data thành công!');
      } else if (uploadNotificationsOnly) {
        await upload_seed.uploadNotifications();
        debugPrint('✅ Đã upload/update notifications thành công!');
      } else {
        await upload_seed.uploadMenuItems();
        debugPrint('✅ Đã upload/update menu items thành công!');
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
