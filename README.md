# FoodGo - Ứng dụng đặt đồ ăn trực tuyến 🍔

<p align="center">
  <img src="foodgo/assets/logo/logo_light.jpg" alt="FoodGo Logo" width="200"/>
</p>

<p align="center">
  <strong>Ứng dụng đặt món ăn trực tuyến hiện đại với Flutter & AI Chatbot</strong>
</p>

---

## 📖 Giới thiệu

**FoodGo** là một ứng dụng đặt đồ ăn trực tuyến được phát triển bằng **Flutter**, tích hợp với **Firebase** và hỗ trợ **chatbot AI thông minh** sử dụng **Rasa**. Ứng dụng cung cấp trải nghiệm đặt món ăn tiện lợi với giao diện thân thiện, thanh toán QR code, và nhiều tính năng hiện đại.

### 🎯 Mục tiêu dự án
- Xây dựng một nền tảng đặt đồ ăn hoàn chỉnh cho mobile
- Tích hợp AI chatbot để hỗ trợ khách hàng tự động
- Ứng dụng kiến trúc sạch (Clean Architecture) và state management với Provider
- Sử dụng Firebase làm backend (Authentication, Firestore, Cloud Functions)

---

## ✨ Tính năng chính

### 📱 Ứng dụng di động (Flutter)

#### 🔐 Xác thực & Quản lý người dùng
- Đăng ký, đăng nhập bằng **email/mật khẩu**
- Đăng nhập nhanh với **Google Sign-In**
- Xác thực OTP qua email
- Quản lý thông tin cá nhân và avatar

#### 🍽️ Duyệt & Đặt món
- Xem danh sách món ăn theo **danh mục** (categories)
- Hình ảnh món ăn chất lượng cao với **cached images**
- Tìm kiếm món ăn theo tên, giá, danh mục
- Xem chi tiết món ăn với mô tả, giá, đánh giá

#### 🛒 Giỏ hàng & Thanh toán
- Quản lý giỏ hàng: thêm/xóa/điều chỉnh số lượng món
- Áp dụng **voucher giảm giá** khi thanh toán
- Thanh toán qua **QR code VietQR**
- Tự động tạo QR code thanh toán với thông tin đơn hàng

#### 📦 Quản lý đơn hàng
- Theo dõi trạng thái đơn hàng **theo thời gian thực**
- Lịch sử đơn hàng đầy đủ
- Chi tiết đơn hàng: món ăn, giá, địa chỉ giao hàng
- Các trạng thái: Đang xử lý → Đang giao → Hoàn thành

#### 📍 Địa chỉ giao hàng
- Lưu và quản lý **nhiều địa chỉ** giao hàng
- Đặt địa chỉ mặc định
- Tích hợp Google Maps API (tùy chọn)

#### 🔔 Thông báo
- Nhận thông báo về **trạng thái đơn hàng**
- Thông báo **khuyến mãi, voucher mới**
- Tùy chỉnh loại thông báo nhận
- Cài đặt âm thanh và rung cho thông báo

#### 🤖 Chatbot AI hỗ trợ
- Tương tác với chatbot AI để được **tư vấn món ăn**
- Hỏi về giá, menu, thông tin món
- Đặt hàng trực tiếp qua chat
- Hỗ trợ tiếng Việt tự nhiên

#### 🎁 Hệ thống Voucher & Rewards
- Áp dụng mã giảm giá khi thanh toán
- Tích điểm thành viên
- Nhận voucher từ chương trình khuyến mãi

#### ⭐ Đánh giá & Phản hồi
- Đánh giá món ăn sau khi hoàn thành đơn hàng
- Xem đánh giá từ người dùng khác
- Rating 5 sao và bình luận

### 🤖 Chatbot AI (Rasa Backend)

- ✅ **Hỗ trợ tiếng Việt** với NLU tùy chỉnh
- ✅ Tư vấn menu và **gợi ý món ăn** phù hợp
- ✅ Hỗ trợ **đặt hàng qua chat**
- ✅ Tra cứu **giá và thông tin** món ăn
- ✅ Kiểm tra **voucher** có sẵn
- ✅ Tìm kiếm món theo **khoảng giá**
- ✅ Giải đáp thắc mắc về dịch vụ

---

## 🛠️ Công nghệ sử dụng

### Frontend (Mobile App)

| Công nghệ | Phiên bản | Mô tả |
|-----------|-----------|-------|
| **Flutter** | 3.8.1+ | Framework phát triển ứng dụng di động đa nền tảng |
| **Dart** | 3.8.1+ | Ngôn ngữ lập trình |
| **Provider** | 6.0.5 | Quản lý state (State Management) |
| **Go Router** | 16.2.4 | Navigation và routing |
| **Firebase Auth** | 5.3.1 | Xác thực người dùng |
| **Cloud Firestore** | 5.4.4 | Cơ sở dữ liệu NoSQL thời gian thực |
| **Google Sign In** | 7.2.0 | Đăng nhập bằng Google |
| **VietQR Flutter** | 1.0.1 | Tạo QR code thanh toán VietQR |
| **Cached Network Image** | 3.3.0 | Cache hình ảnh để tối ưu hiệu suất |
| **HTTP** | 1.1.0 | Gọi API REST |
| **Image Picker** | 1.0.4 | Chọn ảnh từ thiết bị |

### Backend (Chatbot)

| Công nghệ | Mô tả |
|-----------|-------|
| **Rasa** | Framework chatbot AI mã nguồn mở |
| **Python** | 3.8+ |
| **Rasa NLU** | Natural Language Understanding cho tiếng Việt |
| **Rasa Core** | Dialogue management |

### Database & Services

- **Firebase Authentication**: Quản lý người dùng
- **Cloud Firestore**: Lưu trữ dữ liệu (users, foods, orders, vouchers, notifications)
- **Firebase Storage**: Lưu trữ hình ảnh món ăn, avatar

---

## 📁 Cấu trúc dự án

```
foodGo/
├── foodgo/                     # 📱 Ứng dụng Flutter
│   ├── lib/
│   │   ├── core/               # Core utilities & constants
│   │   │   ├── constants/      # App constants, colors, routes
│   │   │   └── theme/          # Theme configuration
│   │   ├── models/             # Data models (User, Food, Order, Cart, etc.)
│   │   ├── pages/              # UI screens/pages
│   │   │   ├── auth/           # Login, Register, Forgot Password
│   │   │   ├── home/           # Home page, Food list
│   │   │   ├── cart/           # Shopping cart
│   │   │   ├── checkout/       # Checkout & Payment
│   │   │   ├── order/          # Order history & details
│   │   │   ├── profile/        # User profile
│   │   │   ├── notification/   # Notifications & settings
│   │   │   ├── address/        # Address management
│   │   │   ├── voucher/        # Voucher list
│   │   │   └── chatbot/        # Chatbot interface
│   │   ├── providers/          # State management với Provider
│   │   │   ├── auth_provider.dart
│   │   │   ├── cart_provider.dart
│   │   │   ├── order_provider.dart
│   │   │   └── ...
│   │   ├── services/           # Business logic & API services
│   │   │   ├── auth_service.dart
│   │   │   ├── food_service.dart
│   │   │   ├── order_service.dart
│   │   │   ├── notification_service.dart
│   │   │   ├── rasa_service.dart     # Rasa chatbot API
│   │   │   └── payment_service.dart
│   │   ├── utils/              # Utility functions & helpers
│   │   ├── widgets/            # Reusable UI widgets
│   │   └── main.dart           # Entry point
│   ├── assets/                 # Static assets
│   │   ├── doAn/               # Food images
│   │   ├── logo/               # App logos
│   │   ├── voucher/            # Voucher images
│   │   ├── icons/              # Icons
│   │   ├── fonts/              # Nunito font family
│   │   ├── data/               # Seed data JSON files
│   │   └── .env                # Environment variables
│   ├── android/                # Android configuration
│   ├── ios/                    # iOS configuration
│   └── pubspec.yaml            # Flutter dependencies
│
├── backend/                    # 🤖 Rasa Chatbot
│   ├── actions/                # Custom actions (Python)
│   │   └── actions.py          # Business logic cho chatbot
│   ├── data/                   # Training data
│   │   ├── nlu.yml             # Natural Language Understanding
│   │   ├── stories.yml         # Conversation flows
│   │   └── rules.yml           # Dialogue rules
│   ├── models/                 # Trained models
│   ├── tests/                  # Test conversations
│   ├── config.yml              # Rasa configuration
│   ├── domain.yml              # Bot domain (intents, entities, responses)
│   ├── endpoints.yml           # API endpoints configuration
│   └── credentials.yml         # Credentials for channels
│
├── deploy-firestore-rules.bat # Script để deploy Firestore rules
├── fix_checkout_complete.py   # Utility script
└── README.md                   # 📄 Documentation
```

---

## 🚀 Hướng dẫn cài đặt

### Yêu cầu hệ thống

- **Flutter SDK**: 3.8.1 trở lên
- **Dart SDK**: 3.8.1 trở lên
- **Android Studio** / **VS Code** (với Flutter extension)
- **Python**: 3.8+ (cho Rasa chatbot)
- **Node.js**: 14+ (cho Firebase CLI - tùy chọn)
- **Git**: Để clone repository

### 1️⃣ Cài đặt Flutter App

```bash
# Clone repository
git clone https://github.com/huypham200104/foodGo.git
cd foodGo/foodgo

# Cài đặt dependencies
flutter pub get

# Kiểm tra cấu hình Flutter
flutter doctor
```

### 2️⃣ Cấu hình Firebase

1. Tạo project mới trên [Firebase Console](https://console.firebase.google.com/)
2. Thêm app Android/iOS vào Firebase project
3. Tải file cấu hình:
   - **Android**: `google-services.json` → đặt vào `android/app/`
   - **iOS**: `GoogleService-Info.plist` → đặt vào `ios/Runner/`
4. Bật các dịch vụ Firebase:
   - **Authentication**: Email/Password và Google Sign-In
   - **Firestore Database**: Tạo database ở chế độ production
   - **Storage**: Để lưu trữ ảnh (tùy chọn)

5. Cấu hình FlutterFire CLI (khuyến nghị):
```bash
# Cài đặt FlutterFire CLI
dart pub global activate flutterfire_cli

# Cấu hình Firebase cho project
flutterfire configure
```

### 3️⃣ Cấu hình biến môi trường

Tạo file `.env` trong `foodgo/assets/.env`:

```env
# Rasa Chatbot API
RASA_API_URL=http://localhost:5005

# Các biến khác (nếu cần)
# FIREBASE_API_KEY=your_api_key
```

### 4️⃣ Chạy ứng dụng Flutter

```bash
# Chạy trên emulator/device
flutter run

# Hoặc chạy với specific device
flutter run -d chrome  # Web
flutter run -d <device_id>  # Specific device
```

### 5️⃣ Cài đặt Rasa Chatbot

```bash
# Di chuyển đến thư mục backend
cd backend

# Tạo virtual environment
python -m venv venv
source venv/bin/activate  # Linux/macOS
# hoặc
venv\Scripts\activate  # Windows

# Cài đặt Rasa
pip install rasa

# Train model
rasa train

# Chạy action server (trong terminal 1)
rasa run actions

# Chạy Rasa server (trong terminal 2)
rasa run --enable-api --cors "*"
```

---

## ⚙️ Cấu hình

### Firebase Firestore Collections

Dự án sử dụng các collections sau trong Firestore:

- **users**: Thông tin người dùng
- **foods**: Danh sách món ăn
- **categories**: Danh mục món ăn
- **orders**: Đơn hàng
- **vouchers**: Mã giảm giá
- **notifications**: Thông báo
- **addresses**: Địa chỉ giao hàng
- **reviews**: Đánh giá món ăn

### Import dữ liệu mẫu

```bash
cd foodgo

# Windows
run_import_ui.bat

# Linux/macOS
./import_menu.sh
```

---

## 📱 Screenshots

*(Screenshots sẽ được bổ sung sau)*

---

## 🧪 Testing

### Flutter App

```bash
cd foodgo
flutter test
```

### Rasa Chatbot

```bash
cd backend
rasa test
```

---

## 🤝 Đóng góp

Mọi đóng góp đều được hoan nghênh! Để đóng góp:

1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

---

## 📄 License

Dự án này được phát triển cho mục đích học tập.

---

## 👥 Tác giả

- **Developer**: Huy Phạm
- **GitHub**: [@huypham200104](https://github.com/huypham200104)

---

## 📞 Liên hệ & Hỗ trợ

Nếu bạn có câu hỏi hoặc cần hỗ trợ, vui lòng:
- Tạo [Issue](https://github.com/huypham200104/foodGo/issues) trên GitHub
- Liên hệ qua GitHub profile

---

<p align="center">
  <strong>Made with ❤️ using Flutter & Rasa</strong>
</p>

<p align="center">
  ⭐ Nếu bạn thấy dự án hữu ích, hãy cho chúng tôi một star! ⭐
</p>