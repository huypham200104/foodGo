# FoodGo - Ứng dụng đặt đồ ăn trực tuyến 🍔

<p align="center">
  <img src="foodgo/assets/logo/logo_light.jpg" alt="FoodGo Logo" width="200"/>
</p>

## 📖 Giới thiệu

**FoodGo** là một ứng dụng đặt đồ ăn trực tuyến được phát triển bằng Flutter, tích hợp với Firebase và hỗ trợ chatbot AI thông minh sử dụng Rasa. Ứng dụng cung cấp trải nghiệm đặt món ăn tiện lợi với giao diện thân thiện và nhiều tính năng hữu ích.

## ✨ Tính năng chính

### 📱 Ứng dụng di động (Flutter)
- **Xác thực người dùng**: Đăng ký, đăng nhập bằng email/mật khẩu hoặc Google Sign-In
- **Duyệt menu**: Xem danh sách món ăn theo danh mục với hình ảnh và mô tả chi tiết
- **Giỏ hàng**: Quản lý giỏ hàng, thêm/xóa món ăn, điều chỉnh số lượng
- **Thanh toán**: Hỗ trợ thanh toán qua QR code (VietQR)
- **Quản lý đơn hàng**: Theo dõi trạng thái đơn hàng theo thời gian thực
- **Địa chỉ giao hàng**: Lưu và quản lý nhiều địa chỉ giao hàng
- **Thông báo**: Nhận thông báo về trạng thái đơn hàng và khuyến mãi
- **Chatbot hỗ trợ**: Tương tác với chatbot AI để được tư vấn và hỗ trợ
- **Voucher**: Áp dụng mã giảm giá khi thanh toán
- **Đánh giá**: Đánh giá món ăn và dịch vụ

### 🤖 Chatbot AI (Rasa)
- Hỗ trợ tiếng Việt
- Tư vấn menu và gợi ý món ăn
- Hỗ trợ đặt hàng qua chat
- Tra cứu giá và thông tin món ăn
- Kiểm tra voucher và thành viên
- Tìm kiếm món theo giá

## 🛠️ Công nghệ sử dụng

### Frontend (Mobile App)
| Công nghệ | Mô tả |
|-----------|-------|
| Flutter | Framework phát triển ứng dụng di động đa nền tảng |
| Dart | Ngôn ngữ lập trình |
| Firebase Auth | Xác thực người dùng |
| Cloud Firestore | Cơ sở dữ liệu NoSQL thời gian thực |
| Provider | Quản lý state |
| Go Router | Navigation và routing |

### Backend (Chatbot)
| Công nghệ | Mô tả |
|-----------|-------|
| Rasa | Framework chatbot AI mã nguồn mở |
| Python | Ngôn ngữ lập trình backend |

## 📁 Cấu trúc dự án

```
foodGo/
├── foodgo/                 # Ứng dụng Flutter
│   ├── lib/
│   │   ├── core/           # Core utilities
│   │   ├── models/         # Data models
│   │   ├── pages/          # UI screens
│   │   ├── providers/      # State management
│   │   ├── services/       # Business logic & API services
│   │   ├── utils/          # Utility functions
│   │   ├── widgets/        # Reusable widgets
│   │   └── main.dart       # Entry point
│   ├── assets/             # Images, fonts, data
│   └── pubspec.yaml        # Dependencies
│
├── backend/                # Rasa Chatbot
│   ├── actions/            # Custom actions
│   ├── data/               # Training data (NLU, stories, rules)
│   ├── models/             # Trained models
│   ├── config.yml          # Rasa configuration
│   ├── domain.yml          # Bot domain definition
│   └── endpoints.yml       # Endpoints configuration
│
└── README.md               # Tài liệu dự án
```

## 🚀 Hướng dẫn cài đặt

### Yêu cầu hệ thống
- **Flutter SDK**: 3.8.1 trở lên
- **Dart SDK**: 3.8.1 trở lên
- **Python**: 3.8+
- **Node.js**: 14+ (cho Firebase CLI)

### 1. Cài đặt Flutter App

```bash
# Clone repository
git clone https://github.com/huypham200104/foodGo.git
cd foodGo

# Cài đặt dependencies
cd foodgo
flutter pub get

# Cấu hình Firebase
# Tạo project trên Firebase Console và thêm file google-services.json (Android)
# hoặc GoogleService-Info.plist (iOS)

# Chạy ứng dụng
flutter run
```

### 2. Cài đặt Rasa Chatbot

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

# Chạy action server
rasa run actions

# Chạy Rasa server (trong terminal khác)
rasa run --enable-api --cors "*"
```

## ⚙️ Cấu hình

### Firebase
1. Tạo project trên [Firebase Console](https://console.firebase.google.com/)
2. Bật Authentication (Email/Password và Google Sign-In)
3. Tạo Firestore Database
4. Thêm file cấu hình Firebase vào project

### Biến môi trường
Tạo file `.env` trong thư mục `foodgo/assets/.env` với các biến cần thiết:
```env
# Cấu hình API endpoints
RASA_API_URL=http://localhost:5005
```

## 📱 Screenshots

*(Screenshots sẽ được bổ sung sau)*

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

## 📄 License

Dự án này được phát triển cho mục đích học tập.

## 👥 Đóng góp

Mọi đóng góp đều được hoan nghênh! Vui lòng tạo Issue hoặc Pull Request.

## 📞 Liên hệ

- **Developer**: Huy Phạm
- **GitHub**: [@huypham200104](https://github.com/huypham200104)

---

<p align="center">Made with ❤️ using Flutter & Rasa</p>