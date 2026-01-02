import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/address_model.dart';
import '../../../services/screen_service.dart' as screen;

/// Simple inline address display widget for checkout page
class CheckoutAddressWidget extends StatelessWidget {
  final AddressModel? address;
  final VoidCallback onAddAddress;
  final VoidCallback onChangeAddress;

  const CheckoutAddressWidget({
    super.key,
    required this.address,
    required this.onAddAddress,
    required this.onChangeAddress,
  });

  @override
  Widget build(BuildContext context) {
    screen.ScreenService.init(context);

    return Container(
      padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Địa chỉ giao hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              if (address != null)
                TextButton(
                  onPressed: onChangeAddress,
                  child: Text(
                    'Thay đổi',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Address content
          if (address == null)
            _buildNoAddress()
          else
            _buildAddressInfo(),
        ],
      ),
    );
  }

  Widget _buildNoAddress() {
    return InkWell(
      onTap: onAddAddress,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.primary.withValues(alpha: 0.05),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_location_alt,
              color: AppColors.primary,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Thêm địa chỉ giao hàng',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Nhấn để thêm địa chỉ mới',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        Row(
          children: [
            Expanded(
              child: Text(
                address!.displayName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (address!.isDefault)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Mặc định',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        
        SizedBox(height: 8),
        
        // Phone
        if (address!.safePhone.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6),
              Text(
                address!.safePhone,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
        ],
        
        // Address
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                address!.displayAddress,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


