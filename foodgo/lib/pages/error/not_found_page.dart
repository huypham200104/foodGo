import 'package:flutter/material.dart';
import '../../core/routes/navigation_helper.dart';

class NotFoundPage extends StatelessWidget {
  final String message;

  const NotFoundPage({
    Key? key,
    this.message = 'Trang không tồn tại',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lỗi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => NavigationHelper.goToHome(),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}