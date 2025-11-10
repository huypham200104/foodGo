import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/address_model.dart';
import '../../../services/screen_service.dart' as screen;

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool showActions;

  const AddressCard({
    super.key,
    required this.address,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    screen.ScreenService.init(context);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderLight,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với tên và default badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      address.safeName,
                      style: TextStyle(
                        fontSize: screen.ScreenService.mediumText,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'MẶC ĐỊNH',
                        style: TextStyle(
                          fontSize: screen.ScreenService.isSmallScreen ? 9 : 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (showActions) ...[
                    SizedBox(width: screen.ScreenService.smallSpacing),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: AppColors.textSecondary),
                              SizedBox(width: screen.ScreenService.smallSpacing),
                              const Text('Sửa'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: AppColors.error),
                              SizedBox(width: screen.ScreenService.smallSpacing),
                              Text('Xóa', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              
              SizedBox(height: screen.ScreenService.smallSpacing),
              
              // Địa chỉ chi tiết
              Text(
                address.detail?.isNotEmpty == true
                    ? address.detail!
                    : address.fullAddress,
                style: TextStyle(
                  fontSize: screen.ScreenService.smallText,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              
              // Phone number nếu có
              if (address.phone?.isNotEmpty == true) ...[
                SizedBox(height: screen.ScreenService.smallSpacing / 2),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: screen.ScreenService.smallSpacing / 2),
                    Text(
                      address.phone!,
                      style: TextStyle(
                        fontSize: screen.ScreenService.smallText,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Selection indicator
              if (isSelected) ...[
                SizedBox(height: screen.ScreenService.smallSpacing),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    SizedBox(width: screen.ScreenService.smallSpacing / 2),
                    Text(
                      'Đã chọn',
                      style: TextStyle(
                        fontSize: screen.ScreenService.smallText,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}