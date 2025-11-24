import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class ChatCartButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ChatCartButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screen.ScreenService.smallSpacing,
        horizontal: screen.ScreenService.mediumSpacing,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          Icons.shopping_cart,
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: screen.ScreenService.mediumText,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: screen.ScreenService.largeSpacing,
            vertical: screen.ScreenService.mediumSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}