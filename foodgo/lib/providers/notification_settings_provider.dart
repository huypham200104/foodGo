import 'package:flutter/foundation.dart';
import '../models/notification_settings_model.dart';
import '../services/notification_settings_service.dart';

/// Provider quản lý state cài đặt thông báo
class NotificationSettingsProvider extends ChangeNotifier {
  NotificationSettingsModel _settings = NotificationSettingsModel.defaultSettings();
  bool _isLoading = false;
  String? _errorMessage;

  NotificationSettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Khởi tạo và load cài đặt
  Future<void> initialize() async {
    await loadSettings();
  }

  /// Load cài đặt từ service
  Future<void> loadSettings() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _settings = await NotificationSettingsService.getUserSettings();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lưu cài đặt
  Future<void> saveSettings(NotificationSettingsModel newSettings) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await NotificationSettingsService.saveUserSettings(newSettings);
      _settings = newSettings;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Bật/tắt tất cả thông báo
  Future<void> toggleAllNotifications(bool enabled) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await NotificationSettingsService.toggleAllNotifications(enabled);
      await loadSettings();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Cập nhật cài đặt bật/tắt thông báo tổng
  Future<void> updateIsEnabled(bool value) async {
    try {
      final updated = _settings.copyWith(isEnabled: value);
      await saveSettings(updated);
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật cài đặt thông báo đơn hàng
  Future<void> updateOrderUpdates(bool value) async {
    try {
      final updated = _settings.copyWith(orderUpdates: value);
      await saveSettings(updated);
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật cài đặt thông báo khuyến mãi
  Future<void> updatePromotions(bool value) async {
    try {
      final updated = _settings.copyWith(promotions: value);
      await saveSettings(updated);
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật cài đặt thông báo chat
  Future<void> updateChatMessages(bool value) async {
    try {
      final updated = _settings.copyWith(chatMessages: value);
      await saveSettings(updated);
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật cài đặt thông báo cập nhật app
  Future<void> updateAppUpdates(bool value) async {
    try {
      final updated = _settings.copyWith(appUpdates: value);
      await saveSettings(updated);
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật cài đặt thông báo từ nhà hàng
  Future<void> updateRestaurantUpdates(bool value) async {
    try {
      final updated = _settings.copyWith(restaurantUpdates: value);
      await saveSettings(updated);
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật cài đặt thông báo điểm thưởng
  Future<void> updateRewardPoints(bool value) async {
    try {
      final updated = _settings.copyWith(rewardPoints: value);
      await saveSettings(updated);
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật cài đặt âm thanh
  Future<void> updateSoundEnabled(bool value) async {
    try {
      final updated = _settings.copyWith(soundEnabled: value);
      await saveSettings(updated);
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật cài đặt rung
  Future<void> updateVibrationEnabled(bool value) async {
    try {
      final updated = _settings.copyWith(vibrationEnabled: value);
      await saveSettings(updated);
    } catch (e) {
      rethrow;
    }
  }

  /// Reset về cài đặt mặc định
  Future<void> resetToDefault() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await NotificationSettingsService.resetToDefault();
      await loadSettings();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
