import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodgo/core/routes/app_routes.dart';
import 'package:foodgo/services/screen_service.dart';
import 'package:foodgo/pages/auth/otp_verification_page.dart';
import 'package:foodgo/pages/auth/widgets/login_header.dart';
import 'package:foodgo/pages/auth/widgets/login_tab_bar.dart';
import 'package:foodgo/pages/auth/widgets/email_login_form.dart';
import 'package:foodgo/pages/auth/widgets/phone_login_form.dart';
import 'package:foodgo/pages/auth/widgets/login_divider.dart';
import 'package:foodgo/pages/auth/widgets/register_button.dart';
import 'package:foodgo/pages/auth/widgets/back_to_home_button.dart'; // ← Import BackToHomeButton

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    ScreenService.init(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: ScreenService.smallSpacing + 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header với logo và tiêu đề
              const LoginHeader(),
              
              // Tab selector
              LoginTabBar(tabController: _tabController),
              SizedBox(height: ScreenService.sectionSpacing + 8),
              
              // Tab content
              Container(
                height: _calculateTabContentHeight(),
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    EmailLoginForm(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      onSignIn: _signInWithEmailPassword,
                      isLoading: _isLoading,
                    ),
                    PhoneLoginForm(
                      phoneController: _phoneController,
                      onSendOTP: _signInWithPhone,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: ScreenService.sectionSpacing),
              
              // Divider
              const LoginDivider(),
              SizedBox(height: ScreenService.sectionSpacing),

              // Register button
              const RegisterButton(),
              SizedBox(height: ScreenService.mediumSpacing), // ← Giảm khoảng cách
              
              // Back to Home button - THÊM MỚI
              const BackToHomeButton(),
              SizedBox(height: ScreenService.largeSpacing + 8),
            ],
          ),
        ),
      ),
    );
  }

  // Tính toán chiều cao TabBarView
  double _calculateTabContentHeight() {
    double emailFormHeight = 56 + ScreenService.formSpacing + 56 + ScreenService.sectionSpacing + 56 + 8;
    double phoneFormHeight = 56 + ScreenService.formSpacing + 40 + ScreenService.sectionSpacing + 56 + 8;
    return emailFormHeight > phoneFormHeight ? emailFormHeight : phoneFormHeight;
  }

  // Auth methods
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
      String message = _getFirebaseErrorMessage(e);
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

    String phoneNumber = _formatPhoneNumber(_phoneController.text.trim());
    setState(() => _isLoading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra. Vui lòng thử lại');
      setState(() => _isLoading = false);
    }
  }

  // Helper methods
  String _formatPhoneNumber(String phoneNumber) {
    if (!phoneNumber.startsWith('+84')) {
      return '+84${phoneNumber.substring(1)}';
    }
    return phoneNumber;
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'wrong-password':
        return 'Mật khẩu không chính xác';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa';
      default:
        return 'Đăng nhập thất bại';
    }
  }

  void _onVerificationCompleted(PhoneAuthCredential credential) async {
    await _auth.signInWithCredential(credential);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  void _onVerificationFailed(FirebaseAuthException e) {
    String message = 'Xác thực số điện thoại thất bại';
    if (e.code == 'billing-not-enabled') {
      message = 'Dịch vụ OTP chưa được kích hoạt. Vui lòng sử dụng email để đăng nhập.';
    } else if (e.code == 'invalid-phone-number') {
      message = 'Số điện thoại không hợp lệ';
    } else if (e.code == 'too-many-requests') {
      message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
    }
    _showErrorSnackBar(message);
    setState(() => _isLoading = false);
  }

  void _onCodeSent(String verificationId, int? resendToken) {
    setState(() => _isLoading = false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OtpVerificationPage(
          verificationId: verificationId,
          phoneNumber: _formatPhoneNumber(_phoneController.text.trim()),
        ),
      ),
    );
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
}