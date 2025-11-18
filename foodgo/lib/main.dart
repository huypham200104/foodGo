import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'pages/my_app.dart';
import 'upload_seed.dart' as upload_seed;

// Seed upload is disabled by default to prevent accidental writes when running the app.
// To perform seed uploads, use the dedicated script or run a separate tool.
// Keeping this a compile-time constant (false) ensures no runtime flag can enable it.
const bool shouldUploadSeed = false;
const bool uploadAllData = bool.fromEnvironment('UPLOAD_ALL_DATA', defaultValue: false);
const bool clearDataBeforeUpload = bool.fromEnvironment('CLEAR_DATA_BEFORE_UPLOAD', defaultValue: false);
// Extra environment guard: only allow destructive clear when SEED_ENV=dev
const String seedEnv = String.fromEnvironment('SEED_ENV', defaultValue: 'prod');
// Optional: upload only notifications (useful for one-off runs)
const bool uploadNotificationsOnly = bool.fromEnvironment('UPLOAD_NOTIFICATIONS_ONLY', defaultValue: false);

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

  // 👈 Seed data upload with safer guards and better error handling
  print('main(): SHOULD_UPLOAD_SEED=$shouldUploadSeed UPLOAD_ALL_DATA=$uploadAllData CLEAR_DATA_BEFORE_UPLOAD=$clearDataBeforeUpload SEED_ENV=$seedEnv');
  if (shouldUploadSeed) {
    try {
      // Decide whether to clear existing seed data first (destructive).
      debugPrint('🗑️  Seed step: clearDataBeforeUpload=$clearDataBeforeUpload');
      if (clearDataBeforeUpload) {
        if (seedEnv != 'dev') {
          debugPrint('⚠️ SEED_ENV is not "dev" — refusing to perform destructive clear.');
        } else {
          try {
            debugPrint('🗑️  Bắt đầu xóa tất cả dữ liệu hiện có trước khi upload seed...');
            await upload_seed.clearAllData();
            debugPrint('✅ Đã xóa tất cả dữ liệu thành công.');
          } catch (e) {
            debugPrint('⚠️ Không thể xóa toàn bộ dữ liệu: $e — tiếp tục cố gắng upload.');
          }
        }
      } else {
        debugPrint('ℹ️ clearDataBeforeUpload=false — skipping destructive clear.');
      }

      // Small delay to let Firestore settle
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('🔄 Bắt đầu upload seed data...');
      if (uploadAllData) {
        await upload_seed.uploadAllSeeds();
        debugPrint('✅ Đã upload tất cả seed data thành công!');
      } else if (uploadNotificationsOnly) {
        await upload_seed.uploadNotifications();
        debugPrint('✅ Đã upload notifications thành công!');
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