import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/theme/app_colors.dart';

class AppIcon extends StatelessWidget {
  final String iconPath;
  final double? size;
  final Color? color;
  final VoidCallback? onTap;

  const AppIcon({
    super.key,
    required this.iconPath,
    this.size,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget svgIcon = SvgPicture.asset(
      'assets/icons/$iconPath.svg',
      width: size ?? 24,
      height: size ?? 24,
      colorFilter: ColorFilter.mode(
        color ?? Theme.of(context).iconTheme.color ?? AppColors.primary,
        BlendMode.srcIn,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: svgIcon,
      );
    }

    return svgIcon;
  }
}
