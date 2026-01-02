import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import 'payment_method_card.dart';

enum PaymentMethod { cash, vietqr }

class PaymentMethodSection extends StatelessWidget {
  final PaymentMethod selectedPaymentMethod;
  final Function(PaymentMethod) onPaymentMethodChanged;

  const PaymentMethodSection({
    super.key,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
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
          Text(
            'Phương thức thanh toán',
            style: TextStyle(
              fontSize: screen.ScreenService.mediumText,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: screen.ScreenService.mediumSpacing),
          
          PaymentMethodCard(
            icon: Icons.payments,
            title: 'Tiền mặt',
            subtitle: 'Thanh toán khi nhận hàng',
            isSelected: selectedPaymentMethod == PaymentMethod.cash,
            onTap: () => onPaymentMethodChanged(PaymentMethod.cash),
          ),
          
          SizedBox(height: screen.ScreenService.smallSpacing),
          
          PaymentMethodCard(
            icon: Icons.qr_code,
            title: 'VietQR',
            subtitle: 'Quét mã QR để thanh toán',
            isSelected: selectedPaymentMethod == PaymentMethod.vietqr,
            onTap: () => onPaymentMethodChanged(PaymentMethod.vietqr),
          ),
        ],
      ),
    );
  }
}
