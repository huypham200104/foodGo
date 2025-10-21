# FoodGo - Flow Documentation

## Tổng quan
FoodGo là ứng dụng đặt món ăn được xây dựng bằng Flutter với Firebase backend. Ứng dụng sử dụng Provider pattern để quản lý state và có hệ thống authentication tích hợp.

## Kiến trúc tổng thể

### 1. State Management
- **ThemeProvider**: Quản lý theme (light/dark mode)
- **AuthProvider**: Quản lý trạng thái đăng nhập và thông tin người dùng
- **CartProvider**: Quản lý giỏ hàng và các thao tác liên quan

### 2. Backend
- **Firebase Authentication**: Xác thực người dùng
- **Cloud Firestore**: Lưu trữ dữ liệu (users, menu_items, cart_items, orders)
- **Cloudinary**: Quản lý hình ảnh

## Flow chi tiết

### 1. Authentication Flow

#### Đăng nhập
```
User nhập email/password → AuthProvider.login() → Firebase Auth → 
Tạo/load UserModel → Update AuthProvider state → Navigate to HomePage
```

#### Đăng xuất
```
User click logout → AuthProvider.logout() → Firebase Auth signOut → 
Clear AuthProvider state → Navigate to LoginPage
```

#### Kiểm tra authentication
- Mỗi khi user truy cập giỏ hàng, tài khoản, hoặc thêm món vào giỏ
- Nếu chưa đăng nhập: hiển thị dialog yêu cầu đăng nhập
- Nếu đã đăng nhập: cho phép thực hiện hành động

### 2. Cart Management Flow

#### Thêm món vào giỏ
```
User click "Add to Cart" → Check authentication → 
If logged in: CartProvider.addToCart() → Update Firestore → Update local state
If not logged in: Show login dialog
```

#### Cập nhật số lượng
```
User click +/- → CartProvider.updateQuantity() → Update Firestore → 
Update local state → UI re-render
```

#### Xóa món khỏi giỏ
```
User click remove → CartProvider.removeFromCart() → Delete from Firestore → 
Update local state → UI re-render
```

### 3. Navigation Flow

#### Bottom Navigation
- **Trang chủ**: Luôn accessible
- **Thông báo**: Luôn accessible
- **Giỏ hàng**: Yêu cầu đăng nhập
- **Tài khoản**: Yêu cầu đăng nhập

#### Profile Page Flow
```
User click "Tài khoản" → Check authentication → 
If logged in: Navigate to ProfilePage
If not logged in: Show login dialog
```

### 4. Data Flow

#### User Data
```
Firebase Auth → AuthProvider → UserModel → UI Components
```

#### Cart Data
```
Firestore cart_items collection → CartProvider → CartItemModel → UI Components
```

#### Menu Data
```
Firestore menu_items collection → MenuPage → MenuItemCard → UI Components
```

## Các tính năng chính

### 1. Profile Page
- Hiển thị thông tin người dùng (avatar, tên, điểm thưởng)
- Menu options (Thông tin cá nhân, Phần thưởng, Sổ địa chỉ, Lịch sử đơn hàng, Món yêu thích)
- Language toggle (VN/EN)
- Action buttons (Đổi mật khẩu, Xóa tài khoản, Đăng xuất)
- Branding section

### 2. Cart Management
- Thêm món vào giỏ (với authentication check)
- Tăng/giảm số lượng (đã sửa lỗi)
- Xóa món khỏi giỏ
- Tính tổng tiền
- Checkout (placeholder)

### 3. Authentication Integration
- Login/Logout functionality
- User state persistence
- Protected routes
- Login required dialogs

## Cấu trúc file

```
lib/
├── core/
│   ├── firebase/
│   └── theme/
├── models/
│   ├── user_model.dart
│   ├── cart_item_model.dart
│   ├── menu_item_model.dart
│   └── address_model.dart
├── providers/
│   ├── theme_provider.dart
│   ├── auth_provider.dart
│   └── cart_provider.dart
├── pages/
│   ├── authentication/
│   ├── home/
│   ├── menu/
│   ├── cart/
│   └── profile/
├── services/
└── widgets/
```

## Dependencies chính

- **flutter**: SDK
- **provider**: State management
- **firebase_auth**: Authentication
- **cloud_firestore**: Database
- **firebase_core**: Firebase initialization
- **image_picker**: Image handling
- **cloudinary**: Image storage

## Cách sử dụng

### 1. Khởi tạo
```dart
// main.dart
await Firebase.initializeApp();
runApp(const MyApp());
```

### 2. Provider Setup
```dart
// my_app.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => CartProvider()),
  ],
  child: MaterialApp(...),
)
```

### 3. Authentication Check
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isLoggedIn) {
      // Show authenticated content
    } else {
      // Show login required
    }
  },
)
```

### 4. Cart Operations
```dart
// Add to cart
cartProvider.addToCart(
  userId: authProvider.currentUser!.id,
  item: menuItem,
);

// Update quantity
cartProvider.updateQuantity(cartItem, newQuantity);

// Remove from cart
cartProvider.removeFromCart(cartItem);
```

## Lưu ý quan trọng

1. **Authentication**: Tất cả các thao tác liên quan đến giỏ hàng và tài khoản đều yêu cầu đăng nhập
2. **State Management**: Sử dụng Provider pattern để quản lý state một cách hiệu quả
3. **Error Handling**: Có xử lý lỗi cho các thao tác Firebase
4. **UI/UX**: Giao diện responsive và user-friendly
5. **Performance**: Sử dụng Consumer để tối ưu re-render

## Cải tiến trong tương lai

1. **Order Management**: Hoàn thiện tính năng đặt hàng
2. **Payment Integration**: Tích hợp thanh toán
3. **Push Notifications**: Thông báo đơn hàng
4. **Offline Support**: Hỗ trợ offline
5. **Advanced Search**: Tìm kiếm nâng cao
6. **Reviews & Ratings**: Đánh giá món ăn
