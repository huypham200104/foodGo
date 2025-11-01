import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodgo/core/theme/app_colors.dart';
import 'package:foodgo/pages/auth/widgets/input_field.dart';
import 'package:foodgo/pages/auth/otp_verification_page.dart';
import 'package:foodgo/core/routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Email/Password controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Phone controllers
  final TextEditingController _phoneController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailPassword() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng nhập thất bại';
      switch (e.code) {
        case 'user-not-found':
          message = 'Không tìm thấy tài khoản với email này';
          break;
        case 'wrong-password':
          message = 'Mật khẩu không chính xác';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        case 'user-disabled':
          message = 'Tài khoản đã bị vô hiệu hóa';
          break;
      }
      _showErrorSnackBar(message);
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra. Vui lòng thử lại');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _signInWithPhone() async {
    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập số điện thoại');
      return;
    }

    String phoneNumber = _phoneController.text.trim();
    if (!phoneNumber.startsWith('+84')) {
      phoneNumber = '+84${phoneNumber.substring(1)}';
    }

    setState(() => _isLoading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String message = 'Xác thực số điện thoại thất bại';
          if (e.code == 'billing-not-enabled') {
            message = 'Dịch vụ OTP chưa được kích hoạt. Vui lòng sử dụng email để đăng nhập.';
          } else {
            switch (e.code) {
              case 'invalid-phone-number':
                message = 'Số điện thoại không hợp lệ';
                break;
              case 'too-many-requests':
                message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
                break;
            }
          }
          _showErrorSnackBar(message);
          setState(() => _isLoading = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _isLoading = false);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OtpVerificationPage(
                verificationId: verificationId,
                phoneNumber: phoneNumber,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra. Vui lòng thử lại');
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Logo và tiêu đề
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Chào mừng trở lại!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Đăng nhập để tiếp tục sử dụng FoodGo',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),

              // Tab selector
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  tabs: const [
                    Tab(
                      height: 50,
                      text: 'Email',
                    ),
                    Tab(
                      height: 50,
                      text: 'Số điện thoại',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Tab content với chiều cao cố định
              SizedBox(
                height: 200,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEmailForm(),
                    _buildPhoneForm(),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'hoặc',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 32),

              // Đăng ký button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.register);
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Tạo tài khoản mới',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        InputField(
          controller: _emailController,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        InputField(
          controller: _passwordController,
          hintText: 'Mật khẩu',
          obscureText: true,
          icon: Icons.lock_outline,
        ),
        const SizedBox(height: 24),
        _buildLoginButton('Đăng nhập', _signInWithEmailPassword),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      children: [
        InputField(
          controller: _phoneController,
          hintText: 'Số điện thoại (VD: 0912345678)',
          keyboardType: TextInputType.phone,
          icon: Icons.phone_outlined,
        ),
        const SizedBox(height: 16),
        Text(
          'Chúng tôi sẽ gửi mã OTP đến số điện thoại của bạn',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildLoginButton('Gửi mã OTP', _signInWithPhone),
      ],
    );
  }

  Widget _buildLoginButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient, // Sử dụng gradient đã định nghĩa sẵn
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}