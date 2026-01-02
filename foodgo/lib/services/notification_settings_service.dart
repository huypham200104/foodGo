import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_settings_model.dart';

/// Service quản lý cài đặt thông báo
class NotificationSettingsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'notification_settings';

  // SharedPreferences keys cho cache local
  static const String _keyIsEnabled = 'notif_enabled';
  static const String _keyOrderUpdates = 'notif_order_updates';
  static const String _keyPromotions = 'notif_promotions';
  static const String _keyChatMessages = 'notif_chat_messages';
  static const String _keyAppUpdates = 'notif_app_updates';
  static const String _keyRestaurantUpdates = 'notif_restaurant_updates';
  static const String _keyRewardPoints = 'notif_reward_points';
  static const String _keySoundEnabled = 'notif_sound';
  static const String _keyVibrationEnabled = 'notif_vibration';

  /// Lấy cài đặt thông báo của người dùng hiện tại
  static Future<NotificationSettingsModel> getUserSettings() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return NotificationSettingsModel.defaultSettings();
    }

    try {
      // Thử lấy từ Firestore trước
      final doc = await _firestore.collection(_collection).doc(userId).get();
      
      if (doc.exists) {
        final settings = NotificationSettingsModel.fromDocument(doc);
        // Cache lại vào local
        await _cacheSettings(settings);
        return settings;
      } else {
        // Nếu chưa có, tạo mới với cài đặt mặc định
        final defaultSettings = NotificationSettingsModel.defaultSettings();
        await saveUserSettings(defaultSettings);
        return defaultSettings;
      }
    } catch (e) {
      // Nếu có lỗi, thử lấy từ cache local
      return await _getCachedSettings();
    }
  }

  /// Lưu cài đặt thông báo
  static Future<void> saveUserSettings(NotificationSettingsModel settings) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    try {
      // Lưu vào Firestore
      await _firestore.collection(_collection).doc(userId).set(
        settings.toMap(),
        SetOptions(merge: true),
      );

      // Cache vào local
      await _cacheSettings(settings);
    } catch (e) {
      throw Exception('Lỗi khi lưu cài đặt thông báo: $e');
    }
  }

  /// Cập nhật một trường cụ thể
  static Future<void> updateSetting(String field, bool value) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    try {
      await _firestore.collection(_collection).doc(userId).update({
        field: value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Cập nhật cache local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_getLocalKey(field), value);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật cài đặt: $e');
    }
  }

  /// Bật/tắt tất cả thông báo
  static Future<void> toggleAllNotifications(bool enabled) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    try {
      final settings = await getUserSettings();
      final updatedSettings = settings.copyWith(
        isEnabled: enabled,
        orderUpdates: enabled,
        promotions: enabled,
        chatMessages: enabled,
        appUpdates: enabled,
        restaurantUpdates: enabled,
        rewardPoints: enabled,
      );
      
      await saveUserSettings(updatedSettings);
    } catch (e) {
      throw Exception('Lỗi khi bật/tắt tất cả thông báo: $e');
    }
  }

  /// Reset về cài đặt mặc định
  static Future<void> resetToDefault() async {
    final defaultSettings = NotificationSettingsModel.defaultSettings();
    await saveUserSettings(defaultSettings);
  }

  /// Lấy stream cài đặt để listen realtime
  static Stream<NotificationSettingsModel> getUserSettingsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(NotificationSettingsModel.defaultSettings());
    }

    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return NotificationSettingsModel.fromDocument(doc);
      } else {
        return NotificationSettingsModel.defaultSettings();
      }
    });
  }

  // ============================================================
  // PRIVATE HELPER METHODS - Cache local
  // ============================================================

  /// Cache cài đặt vào SharedPreferences
  static Future<void> _cacheSettings(NotificationSettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsEnabled, settings.isEnabled);
      await prefs.setBool(_keyOrderUpdates, settings.orderUpdates);
      await prefs.setBool(_keyPromotions, settings.promotions);
      await prefs.setBool(_keyChatMessages, settings.chatMessages);
      await prefs.setBool(_keyAppUpdates, settings.appUpdates);
      await prefs.setBool(_keyRestaurantUpdates, settings.restaurantUpdates);
      await prefs.setBool(_keyRewardPoints, settings.rewardPoints);
      await prefs.setBool(_keySoundEnabled, settings.soundEnabled);
      await prefs.setBool(_keyVibrationEnabled, settings.vibrationEnabled);
    } catch (e) {
      // Bỏ qua lỗi cache
    }
  }

  /// Lấy cài đặt từ cache local
  static Future<NotificationSettingsModel> _getCachedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return NotificationSettingsModel(
        isEnabled: prefs.getBool(_keyIsEnabled) ?? true,
        orderUpdates: prefs.getBool(_keyOrderUpdates) ?? true,
        promotions: prefs.getBool(_keyPromotions) ?? true,
        chatMessages: prefs.getBool(_keyChatMessages) ?? true,
        appUpdates: prefs.getBool(_keyAppUpdates) ?? true,
        restaurantUpdates: prefs.getBool(_keyRestaurantUpdates) ?? true,
        rewardPoints: prefs.getBool(_keyRewardPoints) ?? true,
        soundEnabled: prefs.getBool(_keySoundEnabled) ?? true,
        vibrationEnabled: prefs.getBool(_keyVibrationEnabled) ?? true,
      );
    } catch (e) {
      return NotificationSettingsModel.defaultSettings();
    }
  }

  /// Convert field name sang local key
  static String _getLocalKey(String field) {
    switch (field) {
      case 'isEnabled':
        return _keyIsEnabled;
      case 'orderUpdates':
        return _keyOrderUpdates;
      case 'promotions':
        return _keyPromotions;
      case 'chatMessages':
        return _keyChatMessages;
      case 'appUpdates':
        return _keyAppUpdates;
      case 'restaurantUpdates':
        return _keyRestaurantUpdates;
      case 'rewardPoints':
        return _keyRewardPoints;
      case 'soundEnabled':
        return _keySoundEnabled;
      case 'vibrationEnabled':
        return _keyVibrationEnabled;
      default:
        return field;
    }
  }

  /// Kiểm tra xem người dùng có được nhận loại thông báo này không
  static Future<bool> canReceiveNotificationType(String notificationType) async {
    final settings = await getUserSettings();
    
    if (!settings.isEnabled) {
      return false;
    }

    switch (notificationType) {
      case 'order_update':
        return settings.orderUpdates;
      case 'promotion':
      case 'discount':
      case 'sale_event':
        return settings.promotions;
      case 'chat':
        return settings.chatMessages;
      case 'app_update':
        return settings.appUpdates;
      case 'restaurant':
        return settings.restaurantUpdates;
      case 'reward':
        return settings.rewardPoints;
      default:
        return settings.isEnabled;
    }
  }

  /// Xóa cache local
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsEnabled);
      await prefs.remove(_keyOrderUpdates);
      await prefs.remove(_keyPromotions);
      await prefs.remove(_keyChatMessages);
      await prefs.remove(_keyAppUpdates);
      await prefs.remove(_keyRestaurantUpdates);
      await prefs.remove(_keyRewardPoints);
      await prefs.remove(_keySoundEnabled);
      await prefs.remove(_keyVibrationEnabled);
    } catch (e) {
      // Bỏ qua lỗi
    }
  }
}
