import 'package:flutter/material.dart';
import 'package:foodgo/core/routes/app_routes.dart';
import 'package:foodgo/services/screen_service.dart';

class BackToHomeButton extends StatelessWidget {
  const BackToHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenService.mediumSpacing,
            vertical: ScreenService.smallSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: Colors.grey[600],
          size: ScreenService.smallText + 2,
        ),
        label: Text(
          'Bỏ qua đăng nhập',
          style: TextStyle(
            fontSize: ScreenService.smallText,
            color: Colors.grey[600],
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}