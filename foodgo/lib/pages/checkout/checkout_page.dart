import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../services/screen_service.dart' as screen;
import '../../services/checkout_service.dart';
import '../../services/address_service.dart';
import 'widgets/payment_method_section.dart';
import 'widgets/order_summary_section.dart';
import 'widgets/delivery_address_section.dart';  // 👈 Add this import
import 'widgets/notes_section.dart';
import 'widgets/checkout_bottom_bar.dart';
import 'widgets/empty_cart_widget.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod selectedPaymentMethod = PaymentMethod.cash;
  bool isProcessing = false;
  final TextEditingController notesController = TextEditingController();
  AddressModel? selectedAddress;
  bool isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screen.ScreenService.init(context);
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultAddress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.id == null) {
      setState(() => isLoadingAddress = false);
      return;
    }

    try {
      final defaultAddress = await AddressService.getDefaultAddress(
        authProvider.currentUser!.id
      );

      setState(() {
        selectedAddress = defaultAddress;
        isLoadingAddress = false;
      });
    } catch (e) {
      setState(() => isLoadingAddress = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải địa chỉ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // 👈 Điều hướng đến AddressListPage với select mode
  void _navigateToAddressPage() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addressList,  // 👈 Use existing AddressListPage
      arguments: {
        'selectMode': true,  // 👈 Enable select mode
      },
    );
    
    if (result != null && result is AddressModel) {
      setState(() => selectedAddress = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thanh toán'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<AuthProvider, CartProvider>(
        builder: (context, authProvider, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return const EmptyCartWidget();
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Delivery Address Section
                      if (isLoadingAddress)
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        )
                      else
                        DeliveryAddressSection(
                          address: selectedAddress,
                          onChangeAddress: _navigateToAddressPage,
                        ),
                      
                      SizedBox(height: screen.ScreenService.mediumSpacing),

                      // Order Summary
                      OrderSummarySection(cartItems: cartProvider.items),
                      
                      SizedBox(height: screen.ScreenService.mediumSpacing),

                      // Payment Methods
                      PaymentMethodSection(
                        selectedPaymentMethod: selectedPaymentMethod,
                        onPaymentMethodChanged: (method) {
                          setState(() => selectedPaymentMethod = method);
                        },
                      ),
                      
                      SizedBox(height: screen.ScreenService.mediumSpacing),

                      // Notes Section
                      NotesSection(notesController: notesController),
                    ],
                  ),
                ),
              ),

              // Bottom Checkout Bar
              CheckoutBottomBar(
                totalPrice: cartProvider.totalPrice,
                deliveryFee: 0,
                isProcessing: isProcessing,
                selectedAddress: selectedAddress,
                onPlaceOrder: () => _processOrder(cartProvider, authProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _processOrder(CartProvider cartProvider, AuthProvider authProvider) async {
    // 👈 Validate address and phone
    if (selectedAddress == null) {
      _showAddressRequiredDialog();
      return;
    }

    if (selectedAddress!.safePhone.isEmpty) {
      _showPhoneRequiredDialog();
      return;
    }

    setState(() => isProcessing = true);

    try {
      final orderId = await CheckoutService.processOrder(
        cartProvider: cartProvider,
        authProvider: authProvider,
        deliveryAddress: selectedAddress!,
        paymentMethod: selectedPaymentMethod == PaymentMethod.cash ? 'cash' : 'bank',
        notes: notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt hàng thành công!'),
            backgroundColor: AppColors.success,
          ),
        );

        // 👈 Fix clearCart - xóa parameter
        cartProvider.clearCart(cartProvider.clearCart(authProvider.currentUser!.id) as String);

        // Return to home
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        // TODO: Navigate to order tracking
        // Navigator.pushNamed(context, AppRoutes.orderTracking, arguments: orderId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đặt hàng: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  void _showAddressRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Cần địa chỉ giao hàng'),
          ],
        ),
        content: Text(
          'Bạn cần chọn địa chỉ giao hàng để tiếp tục đặt hàng.',
          style: TextStyle(
            fontSize: screen.ScreenService.smallText,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToAddressPage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Chọn địa chỉ'),
          ),
        ],
      ),
    );
  }

  void _showPhoneRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.phone, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Cần số điện thoại'),
          ],
        ),
        content: Text(
          'Địa chỉ được chọn chưa có số điện thoại. Vui lòng cập nhật số điện thoại để tiếp tục.',
          style: TextStyle(
            fontSize: screen.ScreenService.smallText,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToAddressPage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cập nhật địa chỉ'),
          ),
        ],
      ),
    );
  }
}