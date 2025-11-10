import 'package:flutter/material.dart';
import 'package:foodgo/pages/auth/widgets/input_field.dart';
import 'package:foodgo/pages/auth/widgets/login_button.dart';
import 'package:foodgo/services/screen_service.dart';

class PhoneLoginForm extends StatelessWidget {
  final TextEditingController phoneController;
  final VoidCallback onSendOTP;
  final bool isLoading;

  const PhoneLoginForm({
    super.key,
    required this.phoneController,
    required this.onSendOTP,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputField(
          controller: phoneController,
          hintText: 'Số điện thoại (VD: 0912345678)',
          keyboardType: TextInputType.phone,
          icon: Icons.phone_outlined,
        ),
        SizedBox(height: ScreenService.formSpacing),
        Text(
          'Chúng tôi sẽ gửi mã OTP đến số điện thoại của bạn',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: ScreenService.smallText,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: ScreenService.sectionSpacing),
        LoginButton(
          text: 'Gửi mã OTP',
          onPressed: onSendOTP,
          isLoading: isLoading,
        ),
      ],
    );
  }
}