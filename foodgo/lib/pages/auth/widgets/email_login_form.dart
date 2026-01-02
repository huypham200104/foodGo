import 'package:flutter/material.dart';
import 'package:foodgo/pages/auth/widgets/input_field.dart';
import 'package:foodgo/pages/auth/widgets/login_button.dart';
import 'package:foodgo/services/screen_service.dart';

class EmailLoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSignIn;
  final bool isLoading;

  const EmailLoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onSignIn,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputField(
          controller: emailController,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          icon: Icons.email_outlined,
        ),
        SizedBox(height: ScreenService.formSpacing),
        InputField(
          controller: passwordController,
          hintText: 'Mật khẩu',
          obscureText: true,
          icon: Icons.lock_outline,
        ),
        SizedBox(height: ScreenService.sectionSpacing),
        LoginButton(
          text: 'Đăng nhập',
          onPressed: onSignIn,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
