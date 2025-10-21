import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onToggleTheme;
  const TopBar({super.key, required this.onToggleTheme});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String logo = isDark ? 'assets/logo/logo_dark.jpg' : 'assets/logo/logo_light.jpg';

    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(logo, width: 70, height: 24, fit: BoxFit.cover),
          const SizedBox(width: 8),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.chat_bubble_rounded),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded),
          onPressed: onToggleTheme,
          tooltip: 'Đổi giao diện',
        ),
      ],
    );
  }
}


