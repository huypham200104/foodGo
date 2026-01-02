# Tính năng Cài đặt Thông báo

## Tổng quan
Tính năng cài đặt thông báo cho phép người dùng tùy chỉnh các loại thông báo mà họ muốn nhận từ ứng dụng FoodGo.

## Các file đã được tạo

### 1. Model
- **`models/notification_settings_model.dart`**
  - Model chứa tất cả các cài đặt thông báo
  - Bao gồm: bật/tắt thông báo, loại thông báo, âm thanh, rung
  - Hỗ trợ chuyển đổi từ/sang Firestore

### 2. Service
- **`services/notification_settings_service.dart`**
  - Service xử lý logic lưu/đọc cài đặt từ Firestore
  - Cache local sử dụng SharedPreferences
  - Kiểm tra quyền nhận thông báo theo loại
  - Hỗ trợ Stream để lắng nghe thay đổi realtime

### 3. Provider
- **`providers/notification_settings_provider.dart`**
  - Quản lý state cài đặt thông báo
  - Cung cấp các phương thức cập nhật từng loại thông báo
  - Xử lý loading state và error

### 4. UI
- **`pages/notification/notification_settings_page.dart`**
  - Giao diện trang cài đặt thông báo
  - Master switch để bật/tắt tất cả thông báo
  - Các switch riêng cho từng loại thông báo
  - Cài đặt âm thanh và rung
  - Nút reset về cài đặt mặc định

## Các loại thông báo được hỗ trợ

1. **Cập nhật đơn hàng** (`orderUpdates`)
   - Thông báo về trạng thái đơn hàng
   - Xác nhận đơn hàng, đang giao, đã giao...

2. **Khuyến mãi & Ưu đãi** (`promotions`)
   - Các chương trình khuyến mãi
   - Mã giảm giá
   - Sale sự kiện

3. **Tin nhắn chat** (`chatMessages`)
   - Tin nhắn từ nhà hàng
   - Tin nhắn từ shipper

4. **Cập nhật nhà hàng** (`restaurantUpdates`)
   - Thông báo từ nhà hàng yêu thích
   - Món ăn mới
   - Thay đổi giờ mở cửa

5. **Điểm thưởng** (`rewardPoints`)
   - Tích điểm thành công
   - Quà tặng từ điểm thưởng
   - Thông báo về điểm sắp hết hạn

6. **Cập nhật ứng dụng** (`appUpdates`)
   - Thông báo phiên bản mới
   - Tính năng mới
   - Bảo trì hệ thống

## Cách sử dụng

### 1. Điều hướng đến trang cài đặt
```dart
Navigator.pushNamed(context, '/notification-settings');
// hoặc
Navigator.pushNamed(context, AppRoutes.notificationSettings);
```

### 2. Sử dụng Provider
```dart
// Lấy provider
final provider = context.read<NotificationSettingsProvider>();

// Load cài đặt
await provider.loadSettings();

// Cập nhật một cài đặt
await provider.updateOrderUpdates(true);

// Bật/tắt tất cả
await provider.toggleAllNotifications(false);

// Reset về mặc định
await provider.resetToDefault();
```

### 3. Sử dụng Service trực tiếp
```dart
// Lấy cài đặt
final settings = await NotificationSettingsService.getUserSettings();

// Lưu cài đặt
await NotificationSettingsService.saveUserSettings(newSettings);

// Kiểm tra quyền nhận thông báo
final canReceive = await NotificationSettingsService.canReceiveNotificationType('order_update');
```

### 4. Lắng nghe thay đổi realtime
```dart
NotificationSettingsService.getUserSettingsStream().listen((settings) {
  print('Cài đặt đã thay đổi: $settings');
});
```

## Cấu trúc dữ liệu Firestore

### Collection: `notification_settings`
```
notification_settings/
  {userId}/
    isEnabled: true
    orderUpdates: true
    promotions: true
    chatMessages: true
    appUpdates: true
    restaurantUpdates: true
    rewardPoints: true
    soundEnabled: true
    vibrationEnabled: true
    updatedAt: Timestamp
```

## Dependencies cần thiết

Đảm bảo các package sau đã được thêm vào `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  cloud_firestore: ^4.0.0
  firebase_auth: ^4.0.0
  shared_preferences: ^2.0.0
```

## Lưu ý khi tích hợp

1. **Cache Local**: Service sử dụng SharedPreferences để cache cài đặt offline
2. **Authentication**: Yêu cầu người dùng đăng nhập để lưu cài đặt
3. **Realtime**: Hỗ trợ Stream để cập nhật realtime từ Firestore
4. **Error Handling**: Đã xử lý các trường hợp lỗi network, auth...

## Ví dụ tích hợp với NotificationService

Khi gửi thông báo, kiểm tra cài đặt của người dùng:

```dart
// Trong NotificationService
static Future<void> sendNotification(String userId, String type, Map<String, dynamic> data) async {
  // Kiểm tra xem người dùng có cho phép nhận loại thông báo này không
  final canReceive = await NotificationSettingsService.canReceiveNotificationType(type);
  
  if (!canReceive) {
    print('User has disabled $type notifications');
    return;
  }
  
  // Tiếp tục gửi thông báo...
}
```

## Testing

Để test tính năng:

1. Đăng nhập vào app
2. Vào trang Thông báo
3. Nhấn icon Settings ở góc trên bên phải
4. Thử bật/tắt các loại thông báo
5. Kiểm tra Firestore để xem dữ liệu đã được lưu
6. Thử reset về mặc định

## Screenshots

Trang cài đặt bao gồm:
- ✅ Master switch bật/tắt tất cả thông báo
- ✅ 6 loại thông báo riêng biệt
- ✅ Cài đặt âm thanh và rung
- ✅ Card thông tin hướng dẫn
- ✅ Nút reset về mặc định
- ✅ Loading state và error handling

## Future Enhancements

Có thể mở rộng thêm:
- [ ] Thời gian không làm phiền (Do Not Disturb)
- [ ] Chọn âm thanh thông báo
- [ ] Cường độ rung tùy chỉnh
- [ ] Nhóm thông báo theo priority
- [ ] Lịch sử thông báo
