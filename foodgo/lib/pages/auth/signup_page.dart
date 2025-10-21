import 'package:flutter/material.dart';
import 'package:foodgo/core/theme/app_colors.dart';
import 'package:foodgo/pages/auth/widgets/input_field.dart';
import 'package:foodgo/pages/auth/widgets/social_buttons.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    InputField(
                      hintText: 'Full name',
                      keyboardType: TextInputType.name,
                    ),
                    SizedBox(height: 16),
                    InputField(
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    InputField(
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    InputField(
                      hintText: 'Confirm password',
                      obscureText: true,
                    ),
                    SizedBox(height: 24),
                    _SignupButton(),
                    SizedBox(height: 24),
                    SocialRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignupButton extends StatelessWidget {
  const _SignupButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
      ),
      child: const Text('Sign up'),
    );
  }
}


