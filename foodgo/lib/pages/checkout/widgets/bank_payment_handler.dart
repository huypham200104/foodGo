import 'package:flutter/material.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/address_model.dart';
import '../../../services/qr_service.dart';
import '../../../services/checkout_service.dart';
import '../../../core/theme/app_colors.dart';
import 'payment_method_section.dart';
import 'bank_confirmation_dialog.dart';

class BankPaymentHandler extends StatelessWidget {
  final CartProvider cartProvider;
  final AuthProvider authProvider;
  final AddressModel? selectedAddress;
  final PaymentMethod selectedPaymentMethod;
  final TextEditingController notesController;
  final Function(PaymentMethod) onPaymentMethodChanged;
  final Function(bool) onProcessingChanged;

  // Bank information for VietQR, TienPhong Bank example
  static const String bankCode = "TPB"; // TienPhong Bank code
  static const String accountNumber = "0328559320";
  static const String accountName = "PHAM NGOC HUY";

  const BankPaymentHandler({
    super.key,
    required this.cartProvider,
    required this.authProvider,
    required this.selectedAddress,
    required this.selectedPaymentMethod,
    required this.notesController,
    required this.onPaymentMethodChanged,
    required this.onProcessingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PaymentMethodSection(
      selectedPaymentMethod: selectedPaymentMethod,
      onPaymentMethodChanged: (method) {
        onPaymentMethodChanged(method);
        
        if (method == PaymentMethod.bank) {
          _showBankPaymentQR(context);
        }
      },
    );
  }

  void _showBankPaymentQR(BuildContext context) async {
    try {
      final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
      final totalAmount = cartProvider.totalPrice + 0; // + delivery fee
      
      // 👈 FIXED: Use order ID as description content
      final description = 'FOODGO $orderId';
      
      await QRService.showPaymentQR(
        context,
        orderId: orderId,
        amount: totalAmount,
        description: description,
        bankCode: bankCode,
        accountNumber: accountNumber,
        accountName: accountName,
      );
      
      if (context.mounted) {
        _showBankPaymentConfirmation(context, orderId);
      }
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo mã QR thanh toán: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showBankPaymentConfirmation(BuildContext context, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BankConfirmationDialog(
        orderId: orderId,
        amount: cartProvider.totalPrice,
        bankCode: bankCode,
        accountNumber: accountNumber,
        accountName: accountName,
        onConfirmed: () => _processBankOrder(context, orderId),
      ),
    );
  }

  Future<void> _processBankOrder(BuildContext context, String orderId) async {
    onProcessingChanged(true);

    try {
      await CheckoutService.processOrder(
        cartProvider: cartProvider,
        authProvider: authProvider,
        deliveryAddress: selectedAddress!,
        paymentMethod: 'bank_transfer',
        notes: notesController.text.trim(),
        customOrderId: orderId,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Đơn hàng đã được tạo thành công!'),
                Text(
                  'Mã đơn hàng: $orderId',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 4),
          ),
        );

        cartProvider.clearCart(authProvider.currentUser!.id);
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo đơn hàng: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      onProcessingChanged(false);
    }
  }
}