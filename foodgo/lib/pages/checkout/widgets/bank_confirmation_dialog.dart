import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../utils/format_helper.dart';

class BankConfirmationDialog extends StatelessWidget {
  final String orderId;
  final double amount;
  final Function(bool?) onConfirmed; // true: paid, false: later, null: back to cart

  const BankConfirmationDialog({
    super.key,
    required this.orderId,
    required this.amount,
    required this.onConfirmed,
  });

  String _generateVietQRUrl() {
    const bankId = '970418';
    const accountNumber = '1351446432';
    const template = 'r5rNaHG';
    const accountName = 'PHAM NGOC HUY';
    
    final amountInt = amount.toInt();
    final addInfo = 'FOODGO $orderId';
    
    return 'https://api.vietqr.io/image/$bankId-$accountNumber-$template.jpg'
        '?accountName=$accountName'
        '&amount=$amountInt'
        '&addInfo=${Uri.encodeComponent(addInfo)}';
  }

  @override
  Widget build(BuildContext context) {
    const String accountName = 'PHAM NGOC HUY';

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(Icons.qr_code_scanner, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Quét mã VietQR'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Quét mã QR bằng app ngân hàng để thanh toán',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screen.ScreenService.smallText,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16),
            
            // QR Code Image
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(12),
              child: Image.network(
                _generateVietQRUrl(),
                width: 250,
                height: 250,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    width: 250,
                    height: 250,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 250,
                    height: 250,
                    color: AppColors.surface,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        SizedBox(height: 8),
                        Text(
                          'Không thể tải mã QR',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: 16),
            _buildPaymentInfo(accountName),
            SizedBox(height: 12),
            _buildWarningNote(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirmed(null); // Back to cart
          },
          child: Text(
            'Quay lại giỏ hàng',
            style: TextStyle(color: AppColors.error),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirmed(false); // Pay later
          },
          child: Text(
            'Thanh toán sau',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirmed(true); // Paid
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text('Đã chuyển khoản'),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo(String accountName) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Ngân hàng:', 'VietinBank'),
          _buildInfoRow('Tên tài khoản:', accountName),
          _buildInfoRow('Số tiền:', FormatHelper.formatCurrency(amount)),
          _buildInfoRow('Nội dung:', 'FOODGO $orderId'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningNote() {
    return Row(
      children: [
        Icon(Icons.info_outline, size: 16, color: AppColors.warning),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            'Đơn hàng sẽ được xử lý sau khi chúng tôi nhận được thanh toán',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

