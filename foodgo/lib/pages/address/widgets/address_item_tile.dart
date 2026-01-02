import 'package:flutter/material.dart';
import '../../../models/address_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class AddressItemTile extends StatefulWidget {
  final AddressModel address;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AddressItemTile({
    super.key,
    required this.address,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<AddressItemTile> createState() => _AddressItemTileState();
}

class _AddressItemTileState extends State<AddressItemTile> {
  bool _isScreenServiceInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isScreenServiceInitialized) {
      screen.ScreenService.init(context);
      _isScreenServiceInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          border: Border.all(
            color: widget.isSelected ? AppColors.primary : AppColors.textLight,
            width: widget.isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.address.safeLabel, // Sử dụng safeLabel thay vì label
                    style: TextStyle(
                      fontSize: screen.ScreenService.mediumText,
                      fontWeight: FontWeight.w600,
                      color: widget.isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (widget.address.isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screen.ScreenService.smallSpacing,
                      vertical: screen.ScreenService.smallSpacing / 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing / 2),
                    ),
                    child: Text(
                      'Mặc định',
                      style: TextStyle(
                        fontSize: screen.ScreenService.smallText - 2,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (widget.isSelected)
                  Padding(
                    padding: EdgeInsets.only(left: screen.ScreenService.smallSpacing),
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: screen.ScreenService.mediumSpacing,
                    ),
                  ),
              ],
            ),
            SizedBox(height: screen.ScreenService.smallSpacing),
            
            // Sử dụng safe getters và null-aware operators
            Text(
              _buildAddressText(),
              style: TextStyle(
                fontSize: screen.ScreenService.smallText,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            
            // Phone number (nếu có)
            if (widget.address.phone?.isNotEmpty == true) ...[
              SizedBox(height: screen.ScreenService.smallSpacing / 2),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 14,
                    color: AppColors.textLight,
                  ),
                  SizedBox(width: screen.ScreenService.smallSpacing / 2),
                  Text(
                    widget.address.safePhone,
                    style: TextStyle(
                      fontSize: screen.ScreenService.smallText - 1,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
            
            if (widget.onEdit != null || widget.onDelete != null)
              Column(
                children: [
                  SizedBox(height: screen.ScreenService.mediumSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.onEdit != null)
                        TextButton.icon(
                          onPressed: widget.onEdit,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Sửa'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              horizontal: screen.ScreenService.smallSpacing,
                              vertical: screen.ScreenService.smallSpacing / 2,
                            ),
                          ),
                        ),
                      if (widget.onDelete != null)
                        TextButton.icon(
                          onPressed: widget.onDelete,
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Xóa'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: EdgeInsets.symmetric(
                              horizontal: screen.ScreenService.smallSpacing,
                              vertical: screen.ScreenService.smallSpacing / 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Helper method để build address text an toàn
  String _buildAddressText() {
    final parts = <String>[];
    
    // Thêm detail hoặc fullAddress
    final addressText = widget.address.detail?.isNotEmpty == true 
        ? widget.address.detail!
        : widget.address.fullAddress;
    
    if (addressText.isNotEmpty) {
      parts.add(addressText);
    }
    
    // Thêm ward nếu có
    if (widget.address.ward?.isNotEmpty == true) {
      parts.add(widget.address.ward!);
    }
    
    // Thêm district nếu có
    if (widget.address.district?.isNotEmpty == true) {
      parts.add(widget.address.district!);
    }
    
    // Thêm city nếu có
    if (widget.address.city?.isNotEmpty == true) {
      parts.add(widget.address.city!);
    }
    
    return parts.isNotEmpty ? parts.join(', ') : 'Địa chỉ không đầy đủ';
  }
}



