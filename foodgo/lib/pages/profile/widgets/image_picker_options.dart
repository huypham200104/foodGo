import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class ImagePickerOptions extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback? onRemove;

  const ImagePickerOptions({
    super.key,
    required this.onCamera,
    required this.onGallery,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: screen.ScreenService.mediumSpacing),
            
            Text(
              'Chọn ảnh đại diện',
              style: TextStyle(
                fontSize: screen.ScreenService.mediumText,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: screen.ScreenService.mediumSpacing),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: onCamera,
                ),
                ImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Thư viện',
                  onTap: onGallery,
                ),
                if (onRemove != null)
                  ImagePickerOption(
                    icon: Icons.delete,
                    label: 'Xóa ảnh',
                    onTap: onRemove!,
                    color: AppColors.error,
                  ),
              ],
            ),
            SizedBox(height: screen.ScreenService.mediumSpacing),
          ],
        ),
      ),
    );
  }
}

class ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const ImagePickerOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color ?? AppColors.primary,
              size: 24,
            ),
          ),
          SizedBox(height: screen.ScreenService.smallSpacing / 2),
          Text(
            label,
            style: TextStyle(
              fontSize: screen.ScreenService.smallText,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}