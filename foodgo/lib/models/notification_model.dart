import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  appUpdate('app_update'),
  policyChange('policy_change'),
  saleEvent('sale_event'),
  discount('discount'),
  promotion('promotion'),
  orderUpdate('order_update'),
  systemMaintenance('system_maintenance'),
  newFeature('new_feature'),
  restaurant('restaurant'),
  general('general');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.general,
    );
  }
}

enum NotificationPriority {
  low('low'),
  normal('normal'),
  high('high'),
  urgent('urgent');

  const NotificationPriority(this.value);
  final String value;

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NotificationPriority.normal,
    );
  }
}

enum NotificationStatus {
  draft('draft'),
  scheduled('scheduled'),
  sent('sent'),
  expired('expired'),
  cancelled('cancelled');

  const NotificationStatus(this.value);
  final String value;

  static NotificationStatus fromString(String value) {
    return NotificationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => NotificationStatus.draft,
    );
  }
}

enum TargetAudience {
  allUsers('all_users'),
  customers('customers'),
  restaurants('restaurants'),
  specificUsers('specific_users'),
  newUsers('new_users'),
  activeUsers('active_users'),
  inactiveUsers('inactive_users');

  const TargetAudience(this.value);
  final String value;

  static TargetAudience fromString(String value) {
    return TargetAudience.values.firstWhere(
      (audience) => audience.value == value,
      orElse: () => TargetAudience.allUsers,
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final NotificationStatus status;
  final TargetAudience targetAudience;
  final List<String> targetUserIds; // Specific user IDs if targetAudience is 'specific_users'
  final String? imageUrl;
  final String? iconUrl;
  final Map<String, dynamic>? actionData; // Deep link data or action parameters
  final String? actionUrl; // Web URL or deep link
  final String? actionText; // Button text (e.g., "Xem ngay", "Cập nhật")
  final DateTime createdAt;
  final DateTime? scheduledAt; // When to send (null = send immediately)
  final DateTime? expiresAt; // When notification expires
  final DateTime? sentAt; // When actually sent
  final String createdBy; // Admin/system user ID
  final bool isRead;
  final bool isPushNotification; // Send as push notification
  final bool isInAppNotification; // Show in app notification center
  final bool isEmailNotification; // Send via email
  final Map<String, dynamic>? metadata; // Additional data
  final List<String> tags; // For categorization and filtering

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.status = NotificationStatus.draft,
    this.targetAudience = TargetAudience.allUsers,
    this.targetUserIds = const [],
    this.imageUrl,
    this.iconUrl,
    this.actionData,
    this.actionUrl,
    this.actionText,
    required this.createdAt,
    this.scheduledAt,
    this.expiresAt,
    this.sentAt,
    required this.createdBy,
    this.isRead = false,
    this.isPushNotification = true,
    this.isInAppNotification = true,
    this.isEmailNotification = false,
    this.metadata,
    this.tags = const [],
  });

  // Factory constructor từ Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromMap(data, doc.id);
  }

  // Factory constructor từ Map
  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: NotificationType.fromString(map['type'] ?? 'general'),
      priority: NotificationPriority.fromString(map['priority'] ?? 'normal'),
      status: NotificationStatus.fromString(map['status'] ?? 'draft'),
      targetAudience: TargetAudience.fromString(map['targetAudience'] ?? 'all_users'),
      targetUserIds: List<String>.from(map['targetUserIds'] ?? []),
      imageUrl: map['imageUrl'],
      iconUrl: map['iconUrl'],
      actionData: map['actionData'],
      actionUrl: map['actionUrl'],
      actionText: map['actionText'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      scheduledAt: map['scheduledAt'] != null 
          ? (map['scheduledAt'] as Timestamp).toDate() 
          : null,
      expiresAt: map['expiresAt'] != null 
          ? (map['expiresAt'] as Timestamp).toDate() 
          : null,
      sentAt: map['sentAt'] != null 
          ? (map['sentAt'] as Timestamp).toDate() 
          : null,
      createdBy: map['createdBy'] ?? '',
      isRead: map['isRead'] ?? false,
      isPushNotification: map['isPushNotification'] ?? true,
      isInAppNotification: map['isInAppNotification'] ?? true,
      isEmailNotification: map['isEmailNotification'] ?? false,
      metadata: map['metadata'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type.value,
      'priority': priority.value,
      'status': status.value,
      'targetAudience': targetAudience.value,
      'targetUserIds': targetUserIds,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,
      'actionData': actionData,
      'actionUrl': actionUrl,
      'actionText': actionText,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'createdBy': createdBy,
      'isRead': isRead,
      'isPushNotification': isPushNotification,
      'isInAppNotification': isInAppNotification,
      'isEmailNotification': isEmailNotification,
      'metadata': metadata,
      'tags': tags,
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.value,
      'priority': priority.value,
      'status': status.value,
      'targetAudience': targetAudience.value,
      'targetUserIds': targetUserIds,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,
      'actionData': actionData,
      'actionUrl': actionUrl,
      'actionText': actionText,
      'createdAt': createdAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'createdBy': createdBy,
      'isRead': isRead,
      'isPushNotification': isPushNotification,
      'isInAppNotification': isInAppNotification,
      'isEmailNotification': isEmailNotification,
      'metadata': metadata,
      'tags': tags,
    };
  }

  // Copy with modifications
  NotificationModel copyWith({
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    NotificationStatus? status,
    TargetAudience? targetAudience,
    List<String>? targetUserIds,
    String? imageUrl,
    String? iconUrl,
    Map<String, dynamic>? actionData,
    String? actionUrl,
    String? actionText,
    DateTime? scheduledAt,
    DateTime? expiresAt,
    DateTime? sentAt,
    String? createdBy,
    bool? isRead,
    bool? isPushNotification,
    bool? isInAppNotification,
    bool? isEmailNotification,
    Map<String, dynamic>? metadata,
    List<String>? tags,
  }) {
    return NotificationModel(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      targetAudience: targetAudience ?? this.targetAudience,
      targetUserIds: targetUserIds ?? this.targetUserIds,
      imageUrl: imageUrl ?? this.imageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      actionData: actionData ?? this.actionData,
      actionUrl: actionUrl ?? this.actionUrl,
      actionText: actionText ?? this.actionText,
      createdAt: createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      expiresAt: expiresAt ?? this.expiresAt,
      sentAt: sentAt ?? this.sentAt,
      createdBy: createdBy ?? this.createdBy,
      isRead: isRead ?? this.isRead,
      isPushNotification: isPushNotification ?? this.isPushNotification,
      isInAppNotification: isInAppNotification ?? this.isInAppNotification,
      isEmailNotification: isEmailNotification ?? this.isEmailNotification,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
    );
  }

  // Helper getters
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isScheduled => scheduledAt != null && DateTime.now().isBefore(scheduledAt!);
  bool get canBeSent => status == NotificationStatus.draft || status == NotificationStatus.scheduled;
  bool get hasAction => actionUrl != null || actionData != null;
  
  String get displayTime {
    if (sentAt != null) return _formatTime(sentAt!);
    if (scheduledAt != null) return _formatTime(scheduledAt!);
    return _formatTime(createdAt);
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: ${type.value}, status: ${status.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Helper class for notification statistics
class NotificationStats {
  final int totalSent;
  final int totalRead;
  final int totalClicked;
  final double readRate;
  final double clickRate;
  final Map<String, int> typeBreakdown;
  final Map<String, int> priorityBreakdown;

  NotificationStats({
    required this.totalSent,
    required this.totalRead,
    required this.totalClicked,
    required this.typeBreakdown,
    required this.priorityBreakdown,
  }) : readRate = totalSent > 0 ? totalRead / totalSent : 0.0,
       clickRate = totalSent > 0 ? totalClicked / totalSent : 0.0;
}

// Notification templates for common use cases
class NotificationTemplates {
  // App update notification
  static NotificationModel appUpdate({
    required String version,
    required String createdBy,
    String? downloadUrl,
    List<String> features = const [],
  }) {
    return NotificationModel(
      id: '',
      title: 'Cập nhật ứng dụng $version',
      message: 'Phiên bản mới với nhiều tính năng hấp dẫn đã sẵn sàng!\n${features.join('\n• ')}',
      type: NotificationType.appUpdate,
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      actionUrl: downloadUrl,
      actionText: 'Cập nhật ngay',
      tags: ['app', 'update', version],
    );
  }

  // Sale event notification
  static NotificationModel saleEvent({
    required String title,
    required String message,
    required String createdBy,
    DateTime? startTime,
    DateTime? endTime,
    String? imageUrl,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: '',
      title: title,
      message: message,
      type: NotificationType.saleEvent,
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
      scheduledAt: startTime,
      expiresAt: endTime,
      createdBy: createdBy,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      actionText: 'Xem ngay',
      tags: ['sale', 'promotion'],
    );
  }

  // Discount code notification
  static NotificationModel discountCode({
    required String code,
    required int discountPercent,
    required String createdBy,
    DateTime? expiresAt,
    double? minOrderValue,
  }) {
    String formatAmount(double amount) {
      String amountStr = amount.toStringAsFixed(0);
      String result = '';
      int count = 0;
      for (int i = amountStr.length - 1; i >= 0; i--) {
        if (count == 3) {
          result = '.$result';
          count = 0;
        }
        result = '${amountStr[i]}$result';
        count++;
      }
      return '$resultđ';
    }
    final minOrder = minOrderValue != null ? ' cho đơn hàng từ ${formatAmount(minOrderValue)}' : '';
    return NotificationModel(
      id: '',
      title: '🎉 Mã giảm giá $discountPercent%',
      message: 'Sử dụng mã "$code" để được giảm $discountPercent%$minOrder. Nhanh tay kẻo hết!',
      type: NotificationType.discount,
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      createdBy: createdBy,
      actionData: {'code': code, 'discount': discountPercent},
      actionText: 'Sử dụng ngay',
      tags: ['discount', 'voucher', code],
    );
  }

  // Order update notification
  static NotificationModel orderUpdate({
    required String orderId,
    required String status,
    required String message,
    required String createdBy,
    String? restaurantName,
  }) {
    return NotificationModel(
      id: '',
      title: 'Cập nhật đơn hàng #$orderId',
      message: message,
      type: NotificationType.orderUpdate,
      priority: NotificationPriority.normal,
      targetAudience: TargetAudience.specificUsers,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      actionData: {'orderId': orderId, 'status': status},
      actionText: 'Xem chi tiết',
      tags: ['order', orderId, status],
    );
  }
}
