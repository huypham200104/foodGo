import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class NotesSection extends StatelessWidget {
  final TextEditingController notesController;

  const NotesSection({
    super.key,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note,
                color: AppColors.primary,
                size: screen.ScreenService.mediumSpacing,
              ),
              SizedBox(width: screen.ScreenService.smallSpacing),
              Text(
                'Ghi chú',
                style: TextStyle(
                  fontSize: screen.ScreenService.mediumText,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: screen.ScreenService.smallSpacing),
          TextField(
            controller: notesController,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'Ghi chú cho đơn hàng (không bắt buộc)...',
              hintStyle: TextStyle(
                color: AppColors.textLight,
                fontSize: screen.ScreenService.smallText,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
                borderSide: BorderSide(color: AppColors.textLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
                borderSide: BorderSide(color: AppColors.textLight.withOpacity(0.5)),
              ),
              contentPadding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
              counterStyle: TextStyle(
                fontSize: screen.ScreenService.smallText - 2,
                color: AppColors.textLight,
              ),
            ),
            style: TextStyle(
              fontSize: screen.ScreenService.smallText,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}