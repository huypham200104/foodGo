import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../services/screen_service.dart' as screen;
import '../../services/address_service.dart';
import 'widgets/payment_method_section.dart';
import 'widgets/order_summary_section.dart';
import 'widgets/delivery_address_section.dart';
import 'widgets/notes_section.dart';
import 'widgets/checkout_bottom_bar.dart';
import 'widgets/empty_cart_widget.dart';
import 'widgets/bank_payment_handler.dart';
import 'widgets/address_validation_dialogs.dart';

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

  void _navigateToAddressPage() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addressList,
      arguments: {'selectMode': true},
    );
    
    if (result != null && result is AddressModel) {
      setState(() => selectedAddress = result);
    }
  }

  void _onPaymentMethodChanged(PaymentMethod method) {
    setState(() => selectedPaymentMethod = method);
  }

  void _onProcessingChanged(bool processing) {
    setState(() => isProcessing = processing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
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
                      _buildAddressSection(),
                      
                      SizedBox(height: screen.ScreenService.mediumSpacing),

                      // Order Summary
                      OrderSummarySection(cartItems: cartProvider.items),
                      
                      SizedBox(height: screen.ScreenService.mediumSpacing),

                      // Payment Methods & Bank Handler
                      BankPaymentHandler(
                        cartProvider: cartProvider,
                        authProvider: authProvider,
                        selectedAddress: selectedAddress,
                        selectedPaymentMethod: selectedPaymentMethod,
                        notesController: notesController,
                        onPaymentMethodChanged: _onPaymentMethodChanged,
                        onProcessingChanged: _onProcessingChanged,
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Thanh toán'),
      centerTitle: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildAddressSection() {
    if (isLoadingAddress) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    
    return DeliveryAddressSection(
      address: selectedAddress,
      onChangeAddress: _navigateToAddressPage,
    );
  }

  Future<void> _processOrder(CartProvider cartProvider, AuthProvider authProvider) async {
    // Validate address and phone
    if (selectedAddress == null) {
      AddressValidationDialogs.showAddressRequiredDialog(
        context,
        onSelectAddress: _navigateToAddressPage,
      );
      return;
    }

    if (selectedAddress!.safePhone.isEmpty) {
      AddressValidationDialogs.showPhoneRequiredDialog(
        context,
        onUpdateAddress: _navigateToAddressPage,
      );
      return;
    }

    // Bank payment is handled by BankPaymentHandler
    if (selectedPaymentMethod == PaymentMethod.bank) {
      return;
    }

    // Process cash order...
    _onProcessingChanged(true);
    
    try {
      // Your existing cash order processing logic
      // ...
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt hàng thành công!'),
            backgroundColor: AppColors.success,
          ),
        );

        cartProvider.clearCart(authProvider.currentUser!.id);
        Navigator.of(context).popUntil((route) => route.isFirst);
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
        _onProcessingChanged(false);
      }
    }
  }
}