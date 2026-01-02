import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho cài đặt thông báo của người dùng
class NotificationSettingsModel {
  final bool isEnabled; // Bật/tắt tất cả thông báo
  final bool orderUpdates; // Thông báo cập nhật đơn hàng
  final bool promotions; // Thông báo khuyến mãi
  final bool chatMessages; // Thông báo tin nhắn chat
  final bool appUpdates; // Thông báo cập nhật ứng dụng
  final bool restaurantUpdates; // Thông báo từ nhà hàng
  final bool rewardPoints; // Thông báo điểm thưởng
  final bool soundEnabled; // Bật âm thanh
  final bool vibrationEnabled; // Bật rung
  final DateTime? updatedAt;

  const NotificationSettingsModel({
    this.isEnabled = true,
    this.orderUpdates = true,
    this.promotions = true,
    this.chatMessages = true,
    this.appUpdates = true,
    this.restaurantUpdates = true,
    this.rewardPoints = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.updatedAt,
  });

  /// Tạo đối tượng từ Map
  factory NotificationSettingsModel.fromMap(Map<String, dynamic> map) {
    return NotificationSettingsModel(
      isEnabled: map['isEnabled'] ?? true,
      orderUpdates: map['orderUpdates'] ?? true,
      promotions: map['promotions'] ?? true,
      chatMessages: map['chatMessages'] ?? true,
      appUpdates: map['appUpdates'] ?? true,
      restaurantUpdates: map['restaurantUpdates'] ?? true,
      rewardPoints: map['rewardPoints'] ?? true,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Tạo đối tượng từ Firestore document
  factory NotificationSettingsModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationSettingsModel.fromMap(data);
  }

  /// Chuyển đổi thành Map
  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'orderUpdates': orderUpdates,
      'promotions': promotions,
      'chatMessages': chatMessages,
      'appUpdates': appUpdates,
      'restaurantUpdates': restaurantUpdates,
      'rewardPoints': rewardPoints,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Tạo bản sao với các thay đổi
  NotificationSettingsModel copyWith({
    bool? isEnabled,
    bool? orderUpdates,
    bool? promotions,
    bool? chatMessages,
    bool? appUpdates,
    bool? restaurantUpdates,
    bool? rewardPoints,
    bool? soundEnabled,
    bool? vibrationEnabled,
    DateTime? updatedAt,
  }) {
    return NotificationSettingsModel(
      isEnabled: isEnabled ?? this.isEnabled,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      chatMessages: chatMessages ?? this.chatMessages,
      appUpdates: appUpdates ?? this.appUpdates,
      restaurantUpdates: restaurantUpdates ?? this.restaurantUpdates,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Cài đặt mặc định
  factory NotificationSettingsModel.defaultSettings() {
    return const NotificationSettingsModel();
  }

  @override
  String toString() {
    return 'NotificationSettingsModel(isEnabled: $isEnabled, orderUpdates: $orderUpdates, promotions: $promotions, chatMessages: $chatMessages, appUpdates: $appUpdates, restaurantUpdates: $restaurantUpdates, rewardPoints: $rewardPoints, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationSettingsModel &&
        other.isEnabled == isEnabled &&
        other.orderUpdates == orderUpdates &&
        other.promotions == promotions &&
        other.chatMessages == chatMessages &&
        other.appUpdates == appUpdates &&
        other.restaurantUpdates == restaurantUpdates &&
        other.rewardPoints == rewardPoints &&
        other.soundEnabled == soundEnabled &&
        other.vibrationEnabled == vibrationEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      isEnabled,
      orderUpdates,
      promotions,
      chatMessages,
      appUpdates,
      restaurantUpdates,
      rewardPoints,
      soundEnabled,
      vibrationEnabled,
    );
  }
}
