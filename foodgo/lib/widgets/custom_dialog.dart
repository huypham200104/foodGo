import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/screen_service.dart' as screen;

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool scrollable;
  final EdgeInsets? contentPadding;
  final double? width;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.scrollable = true,
    this.contentPadding,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screen.ScreenService.mediumSpacing),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: screen.ScreenService.mediumText,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: width ?? double.maxFinite,
        child: scrollable
            ? SingleChildScrollView(
                child: content,
              )
            : content,
      ),
      contentPadding: contentPadding ??
          EdgeInsets.fromLTRB(
            screen.ScreenService.mediumSpacing,
            screen.ScreenService.smallSpacing,
            screen.ScreenService.mediumSpacing,
            0,
          ),
      actionsPadding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      actions: actions,
    );
  }
}
