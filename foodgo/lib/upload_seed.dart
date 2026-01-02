import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<dynamic>> _readArray(String assetPath, String rootKey) async {
  final String jsonString = await rootBundle.loadString(assetPath);
  final dynamic decoded = json.decode(jsonString);

  // If file is a top-level array, return it directly
  if (decoded is List) return decoded;

  // If file is an object/map, try to extract the array by rootKey
  if (decoded is Map<String, dynamic>) {
    final list = decoded[rootKey];
    if (list is List) return list;
  }

  // Fallback: return empty list
  return const [];
}

Future<void> uploadRestaurants() async {
  final firestore = FirebaseFirestore.instance;
  final restaurants = await _readArray('assets/data/restaurants.json', 'restaurants');
  for (final r in restaurants) {
    final id = (r['id'] ?? '').toString();
    await firestore.collection('restaurants').doc(id.isEmpty ? null : id).set(Map<String, dynamic>.from(r));
  }
}

// Option A: menu_items aligned to MenuItemModel
Future<void> uploadMenuItems() async {
  final firestore = FirebaseFirestore.instance;
  final menu = await _readArray('assets/data/menu_items.json', 'menu');
  for (final m in menu) {
    final id = (m['id'] ?? '').toString();
    await firestore.collection('menu_items').doc(id.isEmpty ? null : id).set(Map<String, dynamic>.from(m));
  }
}

Future<void> uploadVouchers() async {
  final firestore = FirebaseFirestore.instance;
  final vouchers = await _readArray('assets/data/vouchers.json', 'vouchers');
  for (final v in vouchers) {
    final id = (v['id'] ?? '').toString();
    await firestore.collection('vouchers').doc(id.isEmpty ? null : id).set(Map<String, dynamic>.from(v));
  }
}

Future<void> uploadRewards() async {
  final firestore = FirebaseFirestore.instance;
  final rewards = await _readArray('assets/data/rewards.json', 'rewards');
  for (final r in rewards) {
    final userId = (r['userId'] ?? '').toString();
    if (userId.isEmpty) {
      debugPrint('⚠️  Skipping reward without userId: $r');
      continue;
    }
    // Use userId as document ID so RewardService can query by userId
    await firestore.collection('rewards').doc(userId).set(Map<String, dynamic>.from(r));
    debugPrint('✅ Uploaded reward for user: $userId');
  }
}

Future<void> uploadNotifications() async {
  final firestore = FirebaseFirestore.instance;
  final notifications = await _readArray('assets/data/notifications.json', 'notifications');
  int success = 0;
  int failed = 0;

  for (final n in notifications) {
    try {
      final Map<String, dynamic> doc = Map<String, dynamic>.from(n);

      // Convert ISO date strings to Firestore Timestamp if present
      Timestamp? _parseTs(dynamic v) {
        if (v == null) return null;
        if (v is Timestamp) return v;
        if (v is String) {
          try {
            final dt = DateTime.parse(v);
            return Timestamp.fromDate(dt);
          } catch (_) {
            return null;
          }
        }
        return null;
      }

      final createdAt = _parseTs(doc['createdAt']);
      final scheduledAt = _parseTs(doc['scheduledAt']);
      final expiresAt = _parseTs(doc['expiresAt']);
      final sentAt = _parseTs(doc['sentAt']);

      if (createdAt != null) doc['createdAt'] = createdAt;
      if (scheduledAt != null) doc['scheduledAt'] = scheduledAt;
      if (expiresAt != null) doc['expiresAt'] = expiresAt;
      if (sentAt != null) doc['sentAt'] = sentAt;

      await firestore.collection('notifications').add(doc);
      success++;
    } catch (e, st) {
      failed++;
      debugPrint('❌ Failed to upload a notification: $e');
      debugPrint(st.toString());
      // continue with next
    }
  }

  debugPrint('🔔 uploadNotifications completed. success=$success failed=$failed total=${notifications.length}');
}


Future<void> uploadAllSeeds() async {
  await Future.wait([
    uploadRestaurants(),
    uploadMenuItems(),
    uploadVouchers(),
    uploadRewards(),
    uploadNotifications(),

  ]);
}

// 👈 Thêm method xóa tất cả dữ liệu
Future<void> clearAllData() async {
  final firestore = FirebaseFirestore.instance;
  
  try {
    debugPrint('🗑️  Đang xóa dữ liệu từ các collection...');
    
    // Danh sách tất cả collections cần xóa
    final collectionsToDelete = [
      'addresses',
      'cart_items',
      'complaints',
      'menu',
      'menu_items',
      'notifications',
      'orders',
      'restaurants',
      'reviews',
      'rewards',
      'users',
      'vouchers',
      // Thêm các collection khác nếu có
    ];

    // Xóa từng collection
    for (String collectionName in collectionsToDelete) {
      await _deleteCollection(firestore, collectionName);
    }
    
    debugPrint('✅ Đã xóa tất cả dữ liệu thành công!');
    
  } catch (e) {
    debugPrint('❌ Lỗi khi xóa dữ liệu: $e');
    rethrow;
  }
}

// 👈 Method helper để xóa một collection
Future<void> _deleteCollection(FirebaseFirestore firestore, String collectionName) async {
  try {
    debugPrint('   🗑️  Đang xóa collection: $collectionName');
    
    // Lấy tất cả documents trong collection
    final querySnapshot = await firestore.collection(collectionName).get();
    
    if (querySnapshot.docs.isNotEmpty) {
      // Xóa theo batch để tối ưu performance
      WriteBatch batch = firestore.batch();
      int count = 0;
      
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
        count++;
        
        // Firebase Firestore batch limit = 500 operations
        if (count >= 500) {
          await batch.commit();
          batch = firestore.batch();
          count = 0;
          
          // Đợi một chút để tránh rate limiting
          await Future.delayed(Duration(milliseconds: 100));
        }
      }
      
      // Commit batch cuối cùng
      if (count > 0) {
        await batch.commit();
      }
      
      debugPrint('   ✅ Đã xóa ${querySnapshot.docs.length} documents từ $collectionName');
    } else {
      debugPrint('   ℹ️  Collection $collectionName đã trống');
    }
    
  } catch (e) {
    debugPrint('   ❌ Lỗi khi xóa collection $collectionName: $e');
    // Không throw để tiếp tục xóa các collections khác
  }
}

// 👈 Method xóa selective - chỉ xóa những collections được chỉ định
Future<void> clearSpecificData(List<String> collections) async {
  final firestore = FirebaseFirestore.instance;
  
  try {
    debugPrint('🗑️  Đang xóa dữ liệu từ ${collections.length} collections...');
    
    for (String collectionName in collections) {
      await _deleteCollection(firestore, collectionName);
    }
    
    debugPrint('✅ Đã xóa dữ liệu từ các collections được chỉ định!');
    
  } catch (e) {
    debugPrint('❌ Lỗi khi xóa dữ liệu selective: $e');
    rethrow;
  }
}

// 👈 Method xóa dữ liệu cũ (older than specified days)
Future<void> clearOldData({int olderThanDays = 30}) async {
  final firestore = FirebaseFirestore.instance;
  final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
  
  try {
    debugPrint('🗑️  Đang xóa dữ liệu cũ hơn $olderThanDays ngày...');
    
    // Collections có timestamp
    final timestampCollections = ['orders', 'reviews', 'notifications'];
    
    for (String collectionName in timestampCollections) {
      await _deleteOldDocuments(firestore, collectionName, cutoffDate);
    }
    
    debugPrint('✅ Đã xóa dữ liệu cũ thành công!');
    
  } catch (e) {
    debugPrint('❌ Lỗi khi xóa dữ liệu cũ: $e');
    rethrow;
  }
}

// 👈 Helper method xóa documents cũ
Future<void> _deleteOldDocuments(
  FirebaseFirestore firestore, 
  String collectionName, 
  DateTime cutoffDate
) async {
  try {
    debugPrint('   🗑️  Đang xóa documents cũ từ $collectionName...');
    
    // Query documents có createdAt < cutoffDate
    final querySnapshot = await firestore
        .collection(collectionName)
        .where('createdAt', isLessThan: cutoffDate)
        .get();
    
    if (querySnapshot.docs.isNotEmpty) {
      WriteBatch batch = firestore.batch();
      int count = 0;
      
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
        count++;
        
        if (count >= 500) {
          await batch.commit();
          batch = firestore.batch();
          count = 0;
          await Future.delayed(Duration(milliseconds: 100));
        }
      }
      
      if (count > 0) {
        await batch.commit();
      }
      
      debugPrint('   ✅ Đã xóa ${querySnapshot.docs.length} documents cũ từ $collectionName');
    } else {
      debugPrint('   ℹ️  Không có documents cũ trong $collectionName');
    }
    
  } catch (e) {
    debugPrint('   ❌ Lỗi khi xóa documents cũ từ $collectionName: $e');
  }
}

// 👈 Method backup trước khi xóa (optional)
Future<void> backupBeforeClear() async {
  final firestore = FirebaseFirestore.instance;
  
  try {
    debugPrint('💾 Đang backup dữ liệu trước khi xóa...');
    
    // Tạo backup collection với timestamp
    final backupTimestamp = DateTime.now().millisecondsSinceEpoch;
    final backupCollectionName = 'backup_$backupTimestamp';
    
    // Backup important collections
    final importantCollections = ['users', 'restaurants', 'orders'];
    
    for (String collectionName in importantCollections) {
      final querySnapshot = await firestore.collection(collectionName).get();
      
      if (querySnapshot.docs.isNotEmpty) {
        WriteBatch batch = firestore.batch();
        int count = 0;
        
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          final backupDoc = firestore
              .collection(backupCollectionName)
              .doc('${collectionName}_${doc.id}');
              
          batch.set(backupDoc, {
            'originalCollection': collectionName,
            'originalId': doc.id,
            'data': doc.data(),
            'backupTime': FieldValue.serverTimestamp(),
          });
          
          count++;
          if (count >= 500) {
            await batch.commit();
            batch = firestore.batch();
            count = 0;
          }
        }
        
        if (count > 0) {
          await batch.commit();
        }
      }
    }
    
    debugPrint('✅ Backup hoàn tất trong collection: $backupCollectionName');
    
  } catch (e) {
    debugPrint('❌ Lỗi khi backup: $e');
    rethrow;
  }
}



