import 'package:flutter/material.dart';
import 'package:foodgo/services/screen_service.dart';

class LoginDivider extends StatelessWidget {
  const LoginDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenService.smallSpacing),
          child: Text(
            'hoặc',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ScreenService.smallText,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }
}
