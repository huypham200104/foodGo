import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../widgets/custom_input_field.dart';

class ProfileFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  const ProfileFormFields({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Name field
        CustomInputField(
          controller: nameController,
          labelText: 'Họ và tên *',
          prefixIcon: const Icon(Icons.person, color: AppColors.primary),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập họ và tên';
            }
            return null;
          },
        ),
        SizedBox(height: screen.ScreenService.mediumSpacing),
        
        // Phone field
        CustomInputField(
          controller: phoneController,
          labelText: 'Số điện thoại *',
          prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập số điện thoại';
            }
            if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value.trim())) {
              return 'Số điện thoại không hợp lệ';
            }
            return null;
          },
        ),
        SizedBox(height: screen.ScreenService.mediumSpacing),
        
        // Email field (readonly)
        CustomInputField(
          controller: emailController,
          labelText: 'Email',
          prefixIcon: const Icon(Icons.email, color: AppColors.textSecondary),
          readOnly: true,
          enabled: false,
        ),
      ],
    );
  }
}