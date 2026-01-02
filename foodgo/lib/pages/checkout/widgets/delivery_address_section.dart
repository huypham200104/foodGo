import 'package:flutter/material.dart';import '../../../core/theme/app_colors.dart';import '../../../models/address_model.dart';import '../../../services/screen_service.dart' as screen;class DeliveryAddressSection extends StatelessWidget {  final AddressModel? address;  final VoidCallback onChangeAddress;  const DeliveryAddressSection({    super.key,    required this.address,    required this.onChangeAddress,  });  @override  Widget build(BuildContext context) {    screen.ScreenService.init(context);    return Container(      decoration: BoxDecoration(        color: AppColors.surface,        borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),        border: Border.all(color: AppColors.borderLight),        boxShadow: [          BoxShadow(            color: AppColors.shadowLight,            blurRadius: 4,            offset: const Offset(0, 2),          ),        ],      ),      child: Column(        crossAxisAlignment: CrossAxisAlignment.start,        children: [          // Header          Padding(            padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),            child: Row(              children: [                Container(                  padding: const EdgeInsets.all(8),                  decoration: BoxDecoration(                    color: AppColors.primary.withValues(alpha: 0.1),                    borderRadius: BorderRadius.circular(8),                  ),                  child: Icon(                    Icons.location_on,                    color: AppColors.primary,                    size: 20,                  ),                ),                SizedBox(width: screen.ScreenService.smallSpacing),                Expanded(                  child: Text(                    'Địa chỉ giao hàng',                    style: TextStyle(                      fontSize: screen.ScreenService.mediumText,                      fontWeight: FontWeight.w600,                      color: AppColors.textPrimary,                    ),                  ),                ),                TextButton.icon(                  onPressed: onChangeAddress,                  icon: Icon(                    address == null ? Icons.add : Icons.edit,                    size: 16,                    color: AppColors.primary,                  ),                  label: Text(                    address == null ? 'Thêm' : 'Thay đổi',                    style: TextStyle(                      color: AppColors.primary,                      fontSize: screen.ScreenService.smallText,                      fontWeight: FontWeight.w500,                    ),                  ),                  style: TextButton.styleFrom(                    padding: EdgeInsets.symmetric(                      horizontal: screen.ScreenService.smallSpacing,                      vertical: 4,                    ),                    minimumSize: Size.zero,                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,                  ),                ),              ],            ),          ),                    // Divider          Divider(            height: 1,            color: AppColors.borderLight,            indent: screen.ScreenService.mediumSpacing,            endIndent: screen.ScreenService.mediumSpacing,          ),                    // Address Content          Padding(            padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),            child: address == null ? _buildEmptyAddress() : _buildAddressInfo(),          ),        ],      ),    );  }  Widget _buildEmptyAddress() {    return InkWell(      onTap: onChangeAddress,      borderRadius: BorderRadius.circular(8),      child: Container(        width: double.infinity,        padding: const EdgeInsets.all(16),        decoration: BoxDecoration(          border: Border.all(            color: AppColors.primary.withValues(alpha: 0.3),            style: BorderStyle.solid,          ),          borderRadius: BorderRadius.circular(8),          color: AppColors.primary.withValues(alpha: 0.05),        ),        child: Column(          children: [            Icon(              Icons.add_location_alt_outlined,              color: AppColors.primary,              size: 32,            ),            SizedBox(height: screen.ScreenService.smallSpacing),            Text(              'Thêm địa chỉ giao hàng',              style: TextStyle(                fontSize: screen.ScreenService.smallText,                color: AppColors.primary,                fontWeight: FontWeight.w500,              ),            ),            SizedBox(height: 4),            Text(              'Chọn hoặc thêm địa chỉ để tiếp tục đặt hàng',              style: TextStyle(                fontSize: screen.ScreenService.smallText - 1,                color: AppColors.textSecondary,              ),              textAlign: TextAlign.center,            ),          ],
        ]),
      );
  }

  Widget _buildAddressInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and Default badge
        Row(
          children: [
            Expanded(
              child: Text(
                address!.displayName,
                style: TextStyle(
                  fontSize: screen.ScreenService.mediumText,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (address!.isDefault)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screen.ScreenService.smallSpacing,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Mặc định',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screen.ScreenService.smallText - 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        
        SizedBox(height: screen.ScreenService.smallSpacing),
        
        // Phone number
        if (address!.safePhone.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8),
              Text(
                address!.safePhone,
                style: TextStyle(
                  fontSize: screen.ScreenService.smallText,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: screen.ScreenService.smallSpacing),
        ],
        
        // Full Address
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                address!.displayAddress,
                style: TextStyle(
                  fontSize: screen.ScreenService.smallText,
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

