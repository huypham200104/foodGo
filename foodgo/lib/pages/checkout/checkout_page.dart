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
import 'widgets/checkout_address_widget.dart';
import 'widgets/notes_section.dart';
import 'widgets/checkout_bottom_bar.dart';
import 'widgets/empty_cart_widget.dart';
import '../../services/qr_service.dart';
import 'widgets/bank_confirmation_dialog.dart';
import '../../widgets/add_address_widget.dart';
import '../../services/checkout_service.dart';
import 'widgets/delivery_method_section.dart';
import 'widgets/pickup_location_section.dart';
import 'widgets/voucher_section.dart';
import '../../services/voucher_service.dart';
import 'widgets/redeemable_vouchers_widget.dart';
import '../../services/reward_service.dart';
import '../../models/reward_model.dart';
import '../../models/voucher_model.dart';
import '../../utils/format_helper.dart';

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
  
  // ✨ New state variables
  String deliveryMethod = 'delivery'; // 'delivery' or 'pickup'
  TimeOfDay? selectedPickupTime; // Pickup time for store pickup
  String? voucherCode;
  double discountAmount = 0.0;
  final TextEditingController voucherController = TextEditingController();
  
  RewardModel? userReward;
  VoucherModel? selectedRedeemableVoucher;

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
    voucherController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultAddress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.id == null) {
      setState(() => isLoadingAddress = false);
      return;
    }

    try {
      // Load address
      var defaultAddress = await AddressService.getDefaultAddress(
        authProvider.currentUser!.id
      );

      if (defaultAddress == null) {
        final userAddresses = await AddressService.getUserAddresses(
          authProvider.currentUser!.id
        );
        if (userAddresses.isNotEmpty) {
          defaultAddress = userAddresses.first;
        }
      }

      // Load user reward
      final reward = await RewardService.getUserReward(authProvider.currentUser!.id);

      setState(() {
        selectedAddress = defaultAddress;
        userReward = reward;
        isLoadingAddress = false;
      });
    } catch (e) {
      setState(() => isLoadingAddress = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải dữ liệu: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ✨ Calculate Tier Discount Helper
  double _getTierDiscount(double orderTotal) {
    if (userReward != null && userReward!.discountPercentage > 0) {
      return orderTotal * (userReward!.discountPercentage / 100);
    }
    return 0.0;
  }

  void _navigateToAddressPage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (selectedAddress == null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddAddressWidget(
            userId: authProvider.currentUser!.id,
          ),
        ),
      );
      
      if (result == true) {
        _loadDefaultAddress();
      }
    } else {
      final result = await Navigator.pushNamed(
        context,
        AppRoutes.addressList,
        arguments: {'selectMode': true},
      );
      
      if (result != null && result is AddressModel) {
        setState(() => selectedAddress = result);
      }
    }
  }

  void _onPaymentMethodChanged(PaymentMethod method) {
    setState(() => selectedPaymentMethod = method);
  }

  void _onProcessingChanged(bool processing) {
    setState(() => isProcessing = processing);
  }

  // ✨ Delivery Method Toggle
  void _onDeliveryMethodChanged(String method) {
    setState(() {
      deliveryMethod = method;
      // Reset pickup time when switching away from pickup
      if (method != 'pickup') {
        selectedPickupTime = null;
      }
    });
  }

  // ✨ Select Pickup Time
  Future<void> _selectPickupTime() async {
    final now = DateTime.now();
    final initialTime = selectedPickupTime ?? TimeOfDay.now();
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Validate time is within operating hours
      const openHour = 8;
      const closeHour = 22;
      
      if (picked.hour < openHour || picked.hour >= closeHour) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vui lòng chọn giờ trong khung ${openHour}:00 - ${closeHour}:00'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      setState(() {
        selectedPickupTime = picked;
      });
    }
  }

  // ✨ Apply Voucher Logic
  Future<void> _applyVoucher() async {
    if (voucherController.text.isEmpty) return;

    setState(() => isProcessing = true);

    try {
      final code = voucherController.text;
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      final discount = await VoucherService.validateVoucher(
        code: code,
        orderValue: cartProvider.totalPrice,
      );

      setState(() {
        voucherCode = code;
        discountAmount = discount;
        selectedRedeemableVoucher = null; // Deselect redeemable voucher if manual code is applied
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Áp dụng mã giảm giá thành công! Giảm ${FormatHelper.formatCurrency(discount)}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        discountAmount = 0;
        voucherCode = null;
      });
      
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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

  void _onRedeemableVoucherSelected(VoucherModel voucher) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    // Check min order value
    if (cartProvider.totalPrice < voucher.minOrderValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đơn hàng chưa đạt giá trị tối thiểu ${FormatHelper.formatCurrency(voucher.minOrderValue)}'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check expiry
    if (DateTime.now().isAfter(voucher.expiryDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã giảm giá đã hết hạn'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Apply voucher
    setState(() {
      selectedRedeemableVoucher = voucher;
      voucherCode = voucher.code.isNotEmpty ? voucher.code : voucher.id; // Use ID if code is empty
      discountAmount = voucher.discountValue;
      voucherController.clear(); // Clear manual input
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã áp dụng ưu đãi: ${voucher.title}'),
        backgroundColor: AppColors.success,
      ),
    );
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
                      // Delivery Method Section
                      DeliveryMethodSection(
                        selectedMethod: deliveryMethod,
                        onMethodChanged: _onDeliveryMethodChanged,
                      ),
                      
                      SizedBox(height: screen.ScreenService.mediumSpacing),

                      // Delivery Address Section (Only if Delivery)
                      if (deliveryMethod == 'delivery') ...[
                        _buildAddressSection(),
                        SizedBox(height: screen.ScreenService.mediumSpacing),
                      ] else ...[
                        PickupLocationSection(
                          selectedPickupTime: selectedPickupTime,
                          onSelectTime: _selectPickupTime,
                        ),
                        SizedBox(height: screen.ScreenService.mediumSpacing),
                      ],

                      // Order Summary
                      OrderSummarySection(
                        cartItems: cartProvider.items,
                        discountAmount: discountAmount,
                        tierDiscountAmount: _getTierDiscount(cartProvider.totalPrice),
                        deliveryFee: deliveryMethod == 'delivery' ? 30000 : 0,
                      ),
                      
                      SizedBox(height: screen.ScreenService.mediumSpacing),

                      // ✨ Voucher Section
                      VoucherSection(
                        controller: voucherController,
                        onApply: _applyVoucher,
                      ),
                      
                      SizedBox(height: screen.ScreenService.mediumSpacing),

                      // ✨ Redeemable Vouchers Section
                      if (userReward != null && userReward!.redeemableVouchers.isNotEmpty) ...[
                        RedeemableVouchersWidget(
                          vouchers: userReward!.redeemableVouchers,
                          selectedVoucher: selectedRedeemableVoucher,
                          onSelect: _onRedeemableVoucherSelected,
                        ),
                        SizedBox(height: screen.ScreenService.mediumSpacing),
                      ],

                      // Payment Methods
                      PaymentMethodSection(
                        selectedPaymentMethod: selectedPaymentMethod,
                        onPaymentMethodChanged: _onPaymentMethodChanged,
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
                totalPrice: cartProvider.totalPrice - discountAmount - _getTierDiscount(cartProvider.totalPrice), // ✨ Apply both discounts
                deliveryFee: deliveryMethod == 'delivery' ? 30000 : 0, // ✨ Dynamic fee
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
    
    return CheckoutAddressWidget(
      address: selectedAddress,
      onAddAddress: _navigateToAddressPage,
      onChangeAddress: _navigateToAddressPage,
    );
  }

  Future<void> _processOrder(CartProvider cartProvider, AuthProvider authProvider) async {
    // Validate address if delivery
    if (deliveryMethod == 'delivery' && selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn địa chỉ giao hàng'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (deliveryMethod == 'delivery' && selectedAddress!.safePhone.isEmpty) {
      _navigateToAddressPage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng cập nhật số điện thoại trong địa chỉ giao hàng'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate pickup time for store pickup
    if (deliveryMethod == 'pickup' && selectedPickupTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn thời gian nhận đơn'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // VietQR payment - show QR dialog
    if (selectedPaymentMethod == PaymentMethod.vietqr) {
      await _handleVietQRPayment(cartProvider, authProvider);
      return;
    }

    // Process cash order...
    await _createOrder(cartProvider, authProvider, null, 'pending');
  }

  Future<void> _handleVietQRPayment(CartProvider cartProvider, AuthProvider authProvider) async {
    try {
      final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
      final shippingFee = deliveryMethod == 'delivery' ? 30000.0 : 0.0;
      final finalAmount = cartProvider.totalPrice + shippingFee - discountAmount - _getTierDiscount(cartProvider.totalPrice);

      if (!mounted) return;

      // Show VietQR confirmation dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BankConfirmationDialog(
          orderId: orderId,
          amount: finalAmount,
          onConfirmed: (isPaid) async {
            // isPaid is bool? (nullable)
            // null: Back to cart (do nothing, just close dialog)
            // false: Pay later
            // true: Paid
            
            if (isPaid == null) {
              // User clicked "Back to Cart"
              // Dialog is already closed by Navigator.pop inside the dialog
              return; 
            }

            // Create order with appropriate status
            await _createOrder(
              cartProvider, 
              authProvider, 
              orderId, 
              isPaid ? 'processing' : 'pending_payment'
            );
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _createOrder(
    CartProvider cartProvider, 
    AuthProvider authProvider, 
    String? customOrderId,
    String status,
  ) async {
    _onProcessingChanged(true);
    
    try {
      await CheckoutService.createOrderFromCart(
        cartProvider: cartProvider,
        authProvider: authProvider,
        deliveryAddress: selectedAddress ?? AddressModel(
          id: 'store_pickup', 
          userId: '', 
          name: 'Store Pickup', 
          phone: '', 
          street: 'FoodGo Store', 
          detail: 'Pickup at store', 
          isDefault: false
        ),
        paymentMethod: selectedPaymentMethod == PaymentMethod.vietqr ? 'vietqr' : 'cash',
        notes: notesController.text,
        discount: discountAmount + _getTierDiscount(cartProvider.totalPrice),
        voucherCode: voucherCode,
        deliveryMethod: deliveryMethod,
        customOrderId: customOrderId,
        status: status,
      );
      
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

