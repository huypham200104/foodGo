import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../utils/format_helper.dart';
import '../../../models/order_model.dart';
import '../../../models/address_model.dart';
import 'order_info_section.dart';
import 'order_items_section.dart';
import '../../../services/qr_service.dart';
import '../../../services/checkout_service.dart';

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
        width: screen.ScreenService.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: screen.ScreenService.height * 0.8,
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
                      OrderAddressSection(address: order.deliveryAddress!),
                    ],
                    
                    // Items section
                    SizedBox(height: screen.ScreenService.mediumSpacing),
                    OrderItemsSection(items: order.items),

                    // ✨ Pending Payment Section
                    if (order.status == 'pending_payment') ...[
                      SizedBox(height: screen.ScreenService.mediumSpacing),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Thanh toán đơn hàng',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screen.ScreenService.mediumText,
                              ),
                            ),
                            SizedBox(height: 12),
                            QRService.buildQRWidget(
                              qrData: 'FOODGO ${order.id}',
                              size: 200,
                            ),
                            SizedBox(height: 12),
                            _buildBankInfo(),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _confirmTransfer(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text('Đã chuyển khoản'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    color: Colors.white.withValues(alpha: 0.9),
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

  Widget _buildBankInfo() {
    return Column(
      children: [
        _buildInfoRow('Ngân hàng:', 'VietinBank'),
        _buildInfoRow('Tên tài khoản:', 'PHAM NGOC HUY'),
        _buildInfoRow('Nội dung:', 'FOODGO ${order.id}'),
        _buildInfoRow('Số tiền:', FormatHelper.formatCurrency(order.totalPrice)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmTransfer(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Update status
      await CheckoutService.updateOrderStatus(order.id, 'processing');
      await CheckoutService.updatePaymentStatus(order.id, 'paid');

      if (context.mounted) {
        Navigator.pop(context); // Pop loading
        Navigator.pop(context); // Pop detail dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xác nhận thanh toán!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
            border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipient name
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
                      address.name!,
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
              
              // Phone number
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
                      address.phone!,
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
              
              // Note if available
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
                        'Ghi chú: ${address.note!}',
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

