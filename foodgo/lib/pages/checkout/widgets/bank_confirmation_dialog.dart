import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class BankConfirmationDialog extends StatelessWidget {
  final String orderId;
  final double amount;
  final String bankCode;
  final String accountNumber;
  final String accountName;
  final VoidCallback onConfirmed;

  const BankConfirmationDialog({
    super.key,
    required this.orderId,
    required this.amount,
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.qr_code, color: AppColors.primary, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Xác nhận thanh toán',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vui lòng thực hiện chuyển khoản theo thông tin QR code và xác nhận bên dưới.',
            style: TextStyle(
              fontSize: screen.ScreenService.smallText,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16),
          
          // Bank Information Card
          _buildBankInfoCard(),
          
          SizedBox(height: 12),
          
          // Warning Note
          _buildWarningNote(),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Chưa chuyển khoản',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirmed();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Đã chuyển khoản'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBankInfoCard() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBankInfoRow('Ví điện tử:', 'MoMo'),
          _buildBankInfoRow('Số điện thoại:', accountNumber),
          _buildBankInfoRow('Tên tài khoản:', accountName),
          _buildBankInfoRow('Số tiền:', '${amount.toStringAsFixed(0)}đ'),
          _buildBankInfoRow('Nội dung:', 'FOODGO $orderId'),
        ],
      ),
    );
  }

  Widget _buildBankInfoRow(String label, String value) {
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