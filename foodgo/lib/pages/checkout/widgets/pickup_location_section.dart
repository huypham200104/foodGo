import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class PickupLocationSection extends StatelessWidget {
  final TimeOfDay? selectedPickupTime;
  final VoidCallback onSelectTime;

  const PickupLocationSection({
    super.key,
    this.selectedPickupTime,
    required this.onSelectTime,
  });

  // Store operating hours
  static const int openingHour = 8; // 8:00 AM
  static const int closingHour = 22; // 10:00 PM

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Địa chỉ quán',
            style: TextStyle(
              fontSize: screen.ScreenService.mediumText,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: screen.ScreenService.smallSpacing),
          
          // Store Address
          Row(
            children: [
              Icon(Icons.store, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FoodGo Store',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: screen.ScreenService.smallText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '123 Đường ABC, Quận 1, TP.HCM',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: screen.ScreenService.smallText - 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: screen.ScreenService.mediumSpacing),
          Divider(color: AppColors.borderLight, height: 1),
          SizedBox(height: screen.ScreenService.mediumSpacing),
          
          // Operating Hours
          Row(
            children: [
              Icon(Icons.access_time, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Giờ hoạt động:',
                style: TextStyle(
                  fontSize: screen.ScreenService.smallText,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '${openingHour.toString().padLeft(2, '0')}:00 - ${closingHour.toString().padLeft(2, '0')}:00',
                style: TextStyle(
                  fontSize: screen.ScreenService.smallText,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          
          SizedBox(height: screen.ScreenService.mediumSpacing),
          
          // Pickup Time Selector
          InkWell(
            onTap: onSelectTime,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedPickupTime != null 
                      ? AppColors.primary 
                      : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thời gian nhận đơn',
                          style: TextStyle(
                            fontSize: screen.ScreenService.smallText,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          selectedPickupTime != null
                              ? '${selectedPickupTime!.hour.toString().padLeft(2, '0')}:${selectedPickupTime!.minute.toString().padLeft(2, '0')}'
                              : 'Chọn giờ nhận đơn',
                          style: TextStyle(
                            fontSize: screen.ScreenService.mediumText,
                            fontWeight: FontWeight.w600,
                            color: selectedPickupTime != null
                                ? AppColors.textPrimary
                                : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

