import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodgo/upload_seed.dart';
import 'core/firebase/firebase_options.dart'; // Tự động tạo bởi FlutterFire CLI
import 'pages/my_app.dart';
import 'services/cloudinary_service.dart';

Future<void> _clearCollections(List<String> collectionNames) async {
  final firestore = FirebaseFirestore.instance;
  for (final name in collectionNames) {
    final snap = await firestore.collection(name).get();
    if (snap.docs.isEmpty) continue;
    final batch = firestore.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load biến môi trường
  await dotenv.load(fileName: "assets/.env");

  // Khởi tạo Cloudinary
  CloudinaryService.init();

  // 🔥 Khởi tạo Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  //Xóa dữ liệu cũ rồi seed lại

  await _clearCollections([
    'users',
    'addresses',
    'restaurants',
    'menu_items',
    'vouchers',
    'rewards',
    'cart_items',
    'orders',
    'reviews',
    'complaints',
  ]);

  await uploadAllSeeds();

  // Chạy app
  runApp(const MyApp());
}
