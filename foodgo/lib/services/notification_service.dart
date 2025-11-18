// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import '../models/notification_model.dart';
// import '../models/user_model.dart';
// import 'firebase_service.dart';

// class NotificationService {
//   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   static const String _collection = 'notifications';
//   static const String _userNotificationsCollection = 'user_notifications';

//   // ============================================================
//   // CREATE OPERATIONS
//   // ============================================================

//   /// Tạo thông báo mới
//   static Future<String> createNotification(NotificationModel notification) async {
//     try {
//       final docRef = await _firestore.collection(_collection).add(notification.toMap());
      
//       // Nếu là gửi ngay lập tức
//       if (notification.scheduledAt == null || 
//           DateTime.now().isAfter(notification.scheduledAt!)) {
//         await _sendNotificationImmediately(notification.copyWith(), docRef.id);
//       }
      
//       return docRef.id;
//     } catch (e) {
//       throw Exception('Lỗi khi tạo thông báo: $e');
//     }
//   }

//   /// Tạo thông báo từ template
//   static Future<String> createFromTemplate({
//     required NotificationTemplateType template,
//     required Map<String, dynamic> data,
//     required String createdBy,
//   }) async {
//     NotificationModel notification;
    
//     switch (template) {
//       case NotificationTemplateType.appUpdate:
//         notification = NotificationTemplates.appUpdate(
//           version: data['version'],
//           createdBy: createdBy,
//           downloadUrl: data['downloadUrl'],
//           features: List<String>.from(data['features'] ?? []),
//         );
//         break;
        
//       case NotificationTemplateType.saleEvent:
//         notification = NotificationTemplates.saleEvent(
//           title: data['title'],
//           message: data['message'],
//           createdBy: createdBy,
//           startTime: data['startTime'],
//           endTime: data['endTime'],
//           imageUrl: data['imageUrl'],
//           actionUrl: data['actionUrl'],
//         );
//         break;
        
//       case NotificationTemplateType.discountCode:
//         notification = NotificationTemplates.discountCode(
//           code: data['code'],
//           discountPercent: data['discountPercent'],
//           createdBy: createdBy,
//           expiresAt: data['expiresAt'],
//           minOrderValue: data['minOrderValue'],
//         );
//         break;
        
//       case NotificationTemplateType.orderUpdate:
//         notification = NotificationTemplates.orderUpdate(
//           orderId: data['orderId'],
//           status: data['status'],
//           message: data['message'],
//           createdBy: createdBy,
//           restaurantName: data['restaurantName'],
//         );
//         break;
//     }
    
//     return await createNotification(notification);
//   }

//   /// Tạo bulk notifications
//   static Future<List<String>> createBulkNotifications(List<NotificationModel> notifications) async {
//     try {
//       final batch = _firestore.batch();
//       final List<String> documentIds = [];
      
//       for (final notification in notifications) {
//         final docRef = _firestore.collection(_collection).doc();
//         batch.set(docRef, notification.toMap());
//         documentIds.add(docRef.id);
//       }
      
//       await batch.commit();
      
//       // Process immediate notifications
//       for (int i = 0; i < notifications.length; i++) {
//         final notification = notifications[i];
//         if (notification.scheduledAt == null || 
//             DateTime.now().isAfter(notification.scheduledAt!)) {
//           await _sendNotificationImmediately(notification, documentIds[i]);
//         }
//       }
      
//       return documentIds;
//     } catch (e) {
//       throw Exception('Lỗi khi tạo bulk thông báo: $e');
//     }
//   }

//   // ============================================================
//   // READ OPERATIONS
//   // ============================================================

//   /// Lấy thông báo theo ID
//   static Future<NotificationModel?> getNotificationById(String notificationId) async {
//     try {
//       final doc = await _firestore.collection(_collection).doc(notificationId).get();
      
//       if (doc.exists) {
//         return NotificationModel.fromFirestore(doc);
//       }
//       return null;
//     } catch (e) {
//       throw Exception('Lỗi khi lấy thông báo: $e');
//     }
//   }

//   /// Lấy tất cả thông báo với filters
//   static Future<List<NotificationModel>> getNotifications({
//     NotificationType? type,
//     NotificationStatus? status,
//     NotificationPriority? priority,
//     TargetAudience? targetAudience,
//     int limit = 50,
//     DocumentSnapshot? lastDocument,
//   }) async {
//     try {
//       Query query = _firestore.collection(_collection)
//           .orderBy('createdAt', descending: true);
      
//       // Apply filters
//       if (type != null) {
//         query = query.where('type', isEqualTo: type.value);
//       }
//       if (status != null) {
//         query = query.where('status', isEqualTo: status.value);
//       }
//       if (priority != null) {
//         query = query.where('priority', isEqualTo: priority.value);
//       }
//       if (targetAudience != null) {
//         query = query.where('targetAudience', isEqualTo: targetAudience.value);
//       }
      
//       query = query.limit(limit);
      
//       if (lastDocument != null) {
//         query = query.startAfterDocument(lastDocument);
//       }
      
//       final snapshot = await query.get();
      
//       return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
//     } catch (e) {
//       throw Exception('Lỗi khi lấy danh sách thông báo: $e');
//     }
//   }

//   /// Lấy thông báo cho user cụ thể
//   static Future<List<NotificationModel>> getUserNotifications(
//     String userId, {
//     bool unreadOnly = false,
//     int limit = 20,
//     DocumentSnapshot? lastDocument,
//   }) async {
//     try {
//       // Lấy từ user_notifications collection (personalized)
//       Query userQuery = _firestore
//           .collection(_userNotificationsCollection)
//           .where('userId', isEqualTo: userId)
//           .orderBy('createdAt', descending: true);
      
//       if (unreadOnly) {
//         userQuery = userQuery.where('isRead', isEqualTo: false);
//       }
      
//       userQuery = userQuery.limit(limit);
      
//       if (lastDocument != null) {
//         userQuery = userQuery.startAfterDocument(lastDocument);
//       }
      
//       final userSnapshot = await userQuery.get();
//       final userNotifications = userSnapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return NotificationModel.fromMap(data, doc.id);
//       }).toList();
      
//       // Lấy thông báo chung (all_users, customers, etc.)
//       Query generalQuery = _firestore.collection(_collection)
//           .where('targetAudience', whereIn: ['all_users', 'customers'])
//           .where('status', isEqualTo: 'sent')
//           .orderBy('createdAt', descending: true)
//           .limit(limit);
      
//       final generalSnapshot = await generalQuery.get();
//       final generalNotifications = generalSnapshot.docs.map((doc) => 
//           NotificationModel.fromFirestore(doc)).toList();
      
//       // Combine and sort
//       final allNotifications = [...userNotifications, ...generalNotifications];
//       allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
//       return allNotifications.take(limit).toList();
//     } catch (e) {
//       throw Exception('Lỗi khi lấy thông báo user: $e');
//     }
//   }

//   /// Stream thông báo realtime cho user
//   static Stream<List<NotificationModel>> getUserNotificationsStream(String userId) {
//     return _firestore
//         .collection(_userNotificationsCollection)
//         .where('userId', isEqualTo: userId)
//         .orderBy('createdAt', descending: true)
//         .limit(50)
//         .snapshots()
//         .map((snapshot) => 
//             snapshot.docs.map((doc) {
//               final data = doc.data();
//               return NotificationModel.fromMap(data, doc.id);
//             }).toList());
//   }

//   /// Đếm thông báo chưa đọc
//   static Future<int> getUnreadCount(String userId) async {
//     try {
//       final userUnread = await _firestore
//           .collection(_userNotificationsCollection)
//           .where('userId', isEqualTo: userId)
//           .where('isRead', isEqualTo: false)
//           .count()
//           .get();
      
//       final generalUnread = await _firestore
//           .collection(_collection)
//           .where('targetAudience', whereIn: ['all_users', 'customers'])
//           .where('status', isEqualTo: 'sent')
//           .where('createdAt', isGreaterThan: await _getLastReadTime(userId))
//           .count()
//           .get();
      
//       return userUnread.count + generalUnread.count;
//     } catch (e) {
//       throw Exception('Lỗi khi đếm thông báo chưa đọc: $e');
//     }
//   }

//   /// Lấy thông báo scheduled
//   static Future<List<NotificationModel>> getScheduledNotifications() async {
//     try {
//       final snapshot = await _firestore
//           .collection(_collection)
//           .where('status', isEqualTo: 'scheduled')
//           .where('scheduledAt', isLessThanOrEqualTo: Timestamp.now())
//           .get();
      
//       return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
//     } catch (e) {
//       throw Exception('Lỗi khi lấy thông báo scheduled: $e');
//     }
//   }

//   // ============================================================
//   // UPDATE OPERATIONS
//   // ============================================================

//   /// Cập nhật thông báo
//   static Future<void> updateNotification(String notificationId, Map<String, dynamic> updates) async {
//     try {
//       await _firestore.collection(_collection).doc(notificationId).update({
//         ...updates,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       throw Exception('Lỗi khi cập nhật thông báo: $e');
//     }
//   }

//   /// Đánh dấu đã đọc
//   static Future<void> markAsRead(String notificationId, String userId) async {
//     try {
//       // Update in user_notifications if exists
//       final userNotificationQuery = await _firestore
//           .collection(_userNotificationsCollection)
//           .where('notificationId', isEqualTo: notificationId)
//           .where('userId', isEqualTo: userId)
//           .limit(1)
//           .get();
      
//       if (userNotificationQuery.docs.isNotEmpty) {
//         await userNotificationQuery.docs.first.reference.update({
//           'isRead': true,
//           'readAt': FieldValue.serverTimestamp(),
//         });
//       } else {
//         // Create read record for general notifications
//         await _firestore.collection('notification_reads').add({
//           'notificationId': notificationId,
//           'userId': userId,
//           'readAt': FieldValue.serverTimestamp(),
//         });
//       }
//     } catch (e) {
//       throw Exception('Lỗi khi đánh dấu đã đọc: $e');
//     }
//   }

//   /// Đánh dấu tất cả đã đọc
//   static Future<void> markAllAsRead(String userId) async {
//     try {
//       final batch = _firestore.batch();
      
//       // Mark user notifications as read
//       final userNotifications = await _firestore
//           .collection(_userNotificationsCollection)
//           .where('userId', isEqualTo: userId)
//           .where('isRead', isEqualTo: false)
//           .get();
      
//       for (final doc in userNotifications.docs) {
//         batch.update(doc.reference, {
//           'isRead': true,
//           'readAt': FieldValue.serverTimestamp(),
//         });
//       }
      
//       // Update user's last read time for general notifications
//       batch.set(_firestore.collection('user_settings').doc(userId), {
//         'lastReadTime': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
      
//       await batch.commit();
//     } catch (e) {
//       throw Exception('Lỗi khi đánh dấu tất cả đã đọc: $e');
//     }
//   }

//   /// Cập nhật status thông báo
//   static Future<void> updateStatus(String notificationId, NotificationStatus status) async {
//     try {
//       await updateNotification(notificationId, {
//         'status': status.value,
//         if (status == NotificationStatus.sent) 'sentAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       throw Exception('Lỗi khi cập nhật status: $e');
//     }
//   }

//   // ============================================================
//   // DELETE OPERATIONS
//   // ============================================================

//   /// Xóa thông báo
//   static Future<void> deleteNotification(String notificationId) async {
//     try {
//       final batch = _firestore.batch();
      
//       // Delete main notification
//       batch.delete(_firestore.collection(_collection).doc(notificationId));
      
//       // Delete related user notifications
//       final userNotifications = await _firestore
//           .collection(_userNotificationsCollection)
//           .where('notificationId', isEqualTo: notificationId)
//           .get();
      
//       for (final doc in userNotifications.docs) {
//         batch.delete(doc.reference);
//       }
      
//       // Delete read records
//       final readRecords = await _firestore
//           .collection('notification_reads')
//           .where('notificationId', isEqualTo: notificationId)
//           .get();
      
//       for (final doc in readRecords.docs) {
//         batch.delete(doc.reference);
//       }
      
//       await batch.commit();
//     } catch (e) {
//       throw Exception('Lỗi khi xóa thông báo: $e');
//     }
//   }

//   /// Xóa thông báo của user
//   static Future<void> deleteUserNotification(String notificationId, String userId) async {
//     try {
//       final userNotificationQuery = await _firestore
//           .collection(_userNotificationsCollection)
//           .where('notificationId', isEqualTo: notificationId)
//           .where('userId', isEqualTo: userId)
//           .limit(1)
//           .get();
      
//       if (userNotificationQuery.docs.isNotEmpty) {
//         await userNotificationQuery.docs.first.reference.delete();
//       } else {
//         // Add to hidden notifications
//         await _firestore.collection('hidden_notifications').add({
//           'notificationId': notificationId,
//           'userId': userId,
//           'hiddenAt': FieldValue.serverTimestamp(),
//         });
//       }
//     } catch (e) {
//       throw Exception('Lỗi khi xóa thông báo user: $e');
//     }
//   }

//   /// Bulk delete
//   static Future<void> bulkDeleteNotifications(List<String> notificationIds) async {
//     try {
//       final batch = _firestore.batch();
      
//       for (final id in notificationIds) {
//         batch.delete(_firestore.collection(_collection).doc(id));
//       }
      
//       await batch.commit();
//     } catch (e) {
//       throw Exception('Lỗi khi bulk delete: $e');
//     }
//   }

//   // ============================================================
//   // SEND OPERATIONS
//   // ============================================================

//   /// Gửi thông báo ngay lập tức
//   static Future<void> _sendNotificationImmediately(NotificationModel notification, String notificationId) async {
//     try {
//       // Get target users
//       final targetUsers = await _getTargetUsers(notification);
      
//       if (targetUsers.isEmpty) {
//         await updateStatus(notificationId, NotificationStatus.sent);
//         return;
//       }
      
//       final batch = _firestore.batch();
      
//       // Send push notifications
//       if (notification.isPushNotification) {
//         await _sendPushNotifications(notification, targetUsers);
//       }
      
//       // Create user notifications for in-app display
//       if (notification.isInAppNotification) {
//         for (final user in targetUsers) {
//           final userNotificationRef = _firestore.collection(_userNotificationsCollection).doc();
//           batch.set(userNotificationRef, {
//             ...notification.toMap(),
//             'notificationId': notificationId,
//             'userId': user.id,
//           });
//         }
//       }
      
//       // Update main notification status
//       batch.update(_firestore.collection(_collection).doc(notificationId), {
//         'status': NotificationStatus.sent.value,
//         'sentAt': FieldValue.serverTimestamp(),
//         'sentToCount': targetUsers.length,
//       });
      
//       await batch.commit();
      
//       // Send emails if needed
//       if (notification.isEmailNotification) {
//         await _sendEmailNotifications(notification, targetUsers);
//       }
      
//     } catch (e) {
//       throw Exception('Lỗi khi gửi thông báo: $e');
//     }
//   }

//   /// Gửi push notification
//   static Future<void> _sendPushNotifications(NotificationModel notification, List<UserModel> users) async {
//     try {
//       final tokens = users.map((user) => user.fcmToken).where((token) => token != null).toList();
      
//       if (tokens.isEmpty) return;
      
//       final message = MulticastMessage(
//         tokens: tokens.cast<String>(),
//         notification: Notification(
//           title: notification.title,
//           body: notification.message,
//           android: AndroidNotification(
//             channelId: _getChannelId(notification.priority),
//             priority: AndroidNotificationPriority.high,
//             defaultSound: true,
//             defaultVibrateTimings: true,
//             defaultLightSettings: true,
//           ),
//           apple: AppleNotification(
//             sound: AppleNotificationSound.default,
//             badge: 1,
//           ),
//         ),
//         data: {
//           'notificationId': notification.id,
//           'type': notification.type.value,
//           'actionUrl': notification.actionUrl ?? '',
//           'actionData': notification.actionData?.toString() ?? '',
//         },
//       );
      
//       final response = await _messaging.sendMulticast(message);
      
//       // Log results
//       print('Successfully sent: ${response.successCount}');
//       print('Failed: ${response.failureCount}');
      
//     } catch (e) {
//       print('Error sending push notifications: $e');
//     }
//   }

//   /// Gửi email notification (placeholder)
//   static Future<void> _sendEmailNotifications(NotificationModel notification, List<UserModel> users) async {
//     // Implement email sending logic here
//     // Could use Firebase Functions, SendGrid, etc.
//     print('Sending email notifications to ${users.length} users');
//   }

//   /// Process scheduled notifications
//   static Future<void> processScheduledNotifications() async {
//     try {
//       final scheduledNotifications = await getScheduledNotifications();
      
//       for (final notification in scheduledNotifications) {
//         await _sendNotificationImmediately(notification, notification.id);
//       }
//     } catch (e) {
//       print('Error processing scheduled notifications: $e');
//     }
//   }

//   // ============================================================
//   // ANALYTICS & STATISTICS
//   // ============================================================

//   /// Lấy thống kê thông báo
//   static Future<NotificationStats> getNotificationStats({
//     DateTime? startDate,
//     DateTime? endDate,
//   }) async {
//     try {
//       Query query = _firestore.collection(_collection);
      
//       if (startDate != null) {
//         query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
//       }
//       if (endDate != null) {
//         query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
//       }
      
//       final snapshot = await query.get();
//       final notifications = snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
      
//       final totalSent = notifications.where((n) => n.status == NotificationStatus.sent).length;
//       final totalRead = await _getReadCount(notifications.map((n) => n.id).toList());
//       final totalClicked = await _getClickCount(notifications.map((n) => n.id).toList());
      
//       final typeBreakdown = <String, int>{};
//       final priorityBreakdown = <String, int>{};
      
//       for (final notification in notifications) {
//         typeBreakdown[notification.type.value] = (typeBreakdown[notification.type.value] ?? 0) + 1;
//         priorityBreakdown[notification.priority.value] = (priorityBreakdown[notification.priority.value] ?? 0) + 1;
//       }
      
//       return NotificationStats(
//         totalSent: totalSent,
//         totalRead: totalRead,
//         totalClicked: totalClicked,
//         typeBreakdown: typeBreakdown,
//         priorityBreakdown: priorityBreakdown,
//       );
//     } catch (e) {
//       throw Exception('Lỗi khi lấy thống kê: $e');
//     }
//   }

//   /// Track notification click
//   static Future<void> trackNotificationClick(String notificationId, String userId) async {
//     try {
//       await _firestore.collection('notification_clicks').add({
//         'notificationId': notificationId,
//         'userId': userId,
//         'clickedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       print('Error tracking notification click: $e');
//     }
//   }

//   // ============================================================
//   // HELPER METHODS
//   // ============================================================

//   /// Lấy danh sách user target
//   static Future<List<UserModel>> _getTargetUsers(NotificationModel notification) async {
//     try {
//       switch (notification.targetAudience) {
//         case TargetAudience.allUsers:
//           return await FirebaseService.getAllUsers();
          
//         case TargetAudience.customers:
//           return await FirebaseService.getUsersByRole('customer');
          
//         case TargetAudience.restaurants:
//           return await FirebaseService.getUsersByRole('restaurant');
          
//         case TargetAudience.specificUsers:
//           return await FirebaseService.getUsersByIds(notification.targetUserIds);
          
//         case TargetAudience.newUsers:
//           final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
//           return await FirebaseService.getUsersCreatedAfter(thirtyDaysAgo);
          
//         case TargetAudience.activeUsers:
//           final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
//           return await FirebaseService.getActiveUsersSince(sevenDaysAgo);
          
//         case TargetAudience.inactiveUsers:
//           final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
//           return await FirebaseService.getInactiveUsersSince(thirtyDaysAgo);
//       }
//     } catch (e) {
//       print('Error getting target users: $e');
//       return [];
//     }
//   }

//   /// Lấy channel ID cho push notification
//   static String _getChannelId(NotificationPriority priority) {
//     switch (priority) {
//       case NotificationPriority.urgent:
//         return 'urgent_channel';
//       case NotificationPriority.high:
//         return 'high_channel';
//       case NotificationPriority.normal:
//         return 'normal_channel';
//       case NotificationPriority.low:
//         return 'low_channel';
//     }
//   }

//   /// Lấy thời gian đọc cuối cùng của user
//   static Future<Timestamp> _getLastReadTime(String userId) async {
//     try {
//       final doc = await _firestore.collection('user_settings').doc(userId).get();
//       if (doc.exists) {
//         return doc.data()?['lastReadTime'] ?? Timestamp.fromDate(DateTime(2020));
//       }
//       return Timestamp.fromDate(DateTime(2020));
//     } catch (e) {
//       return Timestamp.fromDate(DateTime(2020));
//     }
//   }

//   /// Lấy số lượng đã đọc
//   static Future<int> _getReadCount(List<String> notificationIds) async {
//     try {
//       final readSnapshot = await _firestore
//           .collection('notification_reads')
//           .where('notificationId', whereIn: notificationIds)
//           .count()
//           .get();
//       return readSnapshot.count;
//     } catch (e) {
//       return 0;
//     }
//   }

//   /// Lấy số lượng click
//   static Future<int> _getClickCount(List<String> notificationIds) async {
//     try {
//       final clickSnapshot = await _firestore
//           .collection('notification_clicks')
//           .where('notificationId', whereIn: notificationIds)
//           .count()
//           .get();
//       return clickSnapshot.count;
//     } catch (e) {
//       return 0;
//     }
//   }
// }

// // ============================================================
// // ENUMS & HELPERS
// // ============================================================

// enum NotificationTemplateType {
//   appUpdate,
//   saleEvent,
//   discountCode,
//   orderUpdate,
// }

// // Extension for easy access
// extension NotificationServiceExtension on NotificationService {
//   /// Shortcut để tạo notification cập nhật đơn hàng
//   static Future<String> notifyOrderUpdate({
//     required String orderId,
//     required String userId,
//     required String status,
//     required String message,
//     String? restaurantName,
//   }) async {
//     final notification = NotificationTemplates.orderUpdate(
//       orderId: orderId,
//       status: status,
//       message: message,
//       createdBy: 'system',
//       restaurantName: restaurantName,
//     ).copyWith(
//       targetAudience: TargetAudience.specificUsers,
//       targetUserIds: [userId],
//     );
    
//     return await NotificationService.createNotification(notification);
//   }
  
//   /// Shortcut để gửi thông báo sale
//   static Future<String> notifySaleEvent({
//     required String title,
//     required String message,
//     String? imageUrl,
//     DateTime? startTime,
//     DateTime? endTime,
//   }) async {
//     final notification = NotificationTemplates.saleEvent(
//       title: title,
//       message: message,
//       createdBy: 'admin',
//       startTime: startTime,
//       endTime: endTime,
//       imageUrl: imageUrl,
//     );
    
//     return await NotificationService.createNotification(notification);
//   }
// }