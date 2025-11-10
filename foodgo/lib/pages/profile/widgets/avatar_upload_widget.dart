import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class AvatarUploadWidget extends StatelessWidget {
  final String? currentAvatarUrl;
  final File? selectedImage;
  final bool isUploading;
  final VoidCallback onTap;

  const AvatarUploadWidget({
    super.key,
    this.currentAvatarUrl,
    this.selectedImage,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _getAvatarImage(),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: _getAvatarImage() == null
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: isUploading ? null : onTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUploading ? AppColors.textLight : AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: isUploading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screen.ScreenService.smallSpacing),
        Text(
          isUploading ? 'Đang tải ảnh lên...' : 'Nhấn để thay đổi ảnh đại diện',
          style: TextStyle(
            fontSize: screen.ScreenService.smallText - 2,
            color: isUploading ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  ImageProvider? _getAvatarImage() {
    if (selectedImage != null) {
      return FileImage(selectedImage!);
    } else if (currentAvatarUrl != null && currentAvatarUrl!.isNotEmpty) {
      return NetworkImage(currentAvatarUrl!);
    }
    return null;
  }
}