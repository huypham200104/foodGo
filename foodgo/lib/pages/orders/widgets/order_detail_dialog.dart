import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../models/order_model.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/address_model.dart';
import 'order_info_section.dart';
import 'order_items_section.dart';    // 👈 Add import

class OrderDetailDialog extends StatelessWidget {
  final OrderModel order;

  const OrderDetailDialog({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenService
    screen.ScreenService.init(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: screen.ScreenService.width * 0.9,        // 👈 Sửa: width thay vì screenWidth
        constraints: BoxConstraints(
          maxHeight: screen.ScreenService.height * 0.8,  // 👈 Sửa: height thay vì screenHeight
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order info
                    OrderInfoSection(order: order),
                    
                    // Address section
                    if (order.deliveryAddress != null) ...[
                      SizedBox(height: screen.ScreenService.mediumSpacing),
                      OrderAddressSection(address: order.deliveryAddress!), // 👈 Giữ nguyên
                    ],
                    
                    // Items section
                    SizedBox(height: screen.ScreenService.mediumSpacing),
                    OrderItemsSection(items: order.items), // 👈 Giữ nguyên
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chi tiết đơn hàng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screen.ScreenService.mediumText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '#${order.id}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: screen.ScreenService.smallText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Minimal fallback implementation of OrderAddressSection in case the external
/// widget is not available; it simply renders the address model's string.
class OrderAddressSection extends StatelessWidget {
  final AddressModel address;

  const OrderAddressSection({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Địa chỉ giao hàng',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: screen.ScreenService.smallText + 1,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: screen.ScreenService.smallSpacing),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipient name - 👈 Sử dụng address.name thay vì address.recipientName
              if (address.name?.isNotEmpty == true) ...[
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      address.name!, // 👈 Sử dụng address.name
                      style: TextStyle(
                        fontSize: screen.ScreenService.smallText,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
              ],
              
              // Phone number - 👈 Sử dụng address.phone thay vì address.phoneNumber
              if (address.phone?.isNotEmpty == true) ...[
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      address.phone!, // 👈 Sử dụng address.phone
                      style: TextStyle(
                        fontSize: screen.ScreenService.smallText,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
              ],
              
              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      address.displayAddress,
                      style: TextStyle(
                        fontSize: screen.ScreenService.smallText,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Note if available - 👈 Sử dụng safe check cho nullable
              if (address.note?.isNotEmpty == true) ...[
                SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Ghi chú: ${address.note!}', // 👈 Safe access với !
                        style: TextStyle(
                          fontSize: screen.ScreenService.smallText - 1,
                          color: AppColors.textLight,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}