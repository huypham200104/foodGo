import re

# Read the file
with open('foodgo/lib/pages/checkout/checkout_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Remove address_validation_dialogs import
content = re.sub(r"import 'widgets/address_validation_dialogs\.dart';\r?\n", '', content)

# 2. Replace DeliveryAddressSection with CheckoutAddressWidget
content = content.replace(
    "import 'widgets/delivery_address_section.dart';",
    "import 'widgets/checkout_address_widget.dart';"
)

# 3. Add AddAddressWidget import if not exists
if "import '../../widgets/add_address_widget.dart';" not in content:
    content = re.sub(
        r"(import 'widgets/bank_payment_handler\.dart';)",
        r"\1\nimport '../../widgets/add_address_widget.dart';",
        content
    )

# 4. Replace AddressValidationDialogs calls
content = re.sub(
    r"AddressValidationDialogs\.showAddressRequiredDialog\([^)]+\);",
    """ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn địa chỉ giao hàng'),
          backgroundColor: AppColors.error,
        ),
      );""",
    content,
    flags=re.DOTALL
)

content = re.sub(
    r"AddressValidationDialogs\.showPhoneRequiredDialog\([^)]+\);",
    """_navigateToAddressPage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng cập nhật số điện thoại trong địa chỉ giao hàng'),
          backgroundColor: AppColors.error,
        ),
      );""",
    content,
    flags=re.DOTALL
)

# 5. Update bank payment
content = re.sub(
    r"// Bank payment is handled by BankPaymentHandler\s+if \(selectedPaymentMethod == PaymentMethod\.bank\) \{\s+return;\s+\}",
    """// Bank payment - trigger QR dialog
    if (selectedPaymentMethod == PaymentMethod.bank) {
      _onPaymentMethodChanged(PaymentMethod.bank);
      return;
    }""",
    content,
    flags=re.DOTALL
)

# 6. Update _loadDefaultAddress
old_load = r"""Future<void> _loadDefaultAddress\(\) async \{
    final authProvider = Provider\.of<AuthProvider>\(context, listen: false\);
    if \(authProvider\.currentUser\?\.id == null\) \{
      setState\(\(\) => isLoadingAddress = false\);
      return;
    \}

    try \{
      final defaultAddress = await AddressService\.getDefaultAddress\(
        authProvider\.currentUser!\.id
      \);

      setState\(\(\) \{
        selectedAddress = defaultAddress;
        isLoadingAddress = false;
      \}\);
    \} catch \(e\) \{
      setState\(\(\) => isLoadingAddress = false\);
      if \(mounted\) \{
        ScaffoldMessenger\.of\(context\)\.showSnackBar\(
          SnackBar\(
            content: Text\('Lỗi khi tải địa chỉ: \$e'\),
            backgroundColor: AppColors\.error,
          \),
        \);
      \}
    \}
  \}"""

new_load = """Future<void> _loadDefaultAddress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.id == null) {
      setState(() => isLoadingAddress = false);
      return;
    }

    try {
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
  }"""

content = re.sub(old_load, new_load, content, flags=re.DOTALL)

# 7. Update _navigateToAddressPage
old_nav = r"""void _navigateToAddressPage\(\) async \{
    final result = await Navigator\.pushNamed\(
      context,
      AppRoutes\.addressList,
      arguments: \{'selectMode': true\},
    \);
    
    if \(result != null && result is AddressModel\) \{
      setState\(\(\) => selectedAddress = result\);
    \}
  \}"""

new_nav = """void _navigateToAddressPage() async {
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
  }"""

content = re.sub(old_nav, new_nav, content, flags=re.DOTALL)

# 8. Replace DeliveryAddressSection widget usage
content = content.replace(
    """return DeliveryAddressSection(
      address: selectedAddress,
      onChangeAddress: _navigateToAddressPage,
    );""",
    """return CheckoutAddressWidget(
      address: selectedAddress,
      onAddAddress: _navigateToAddressPage,
      onChangeAddress: _navigateToAddressPage,
    );"""
)

# Write back
with open('foodgo/lib/pages/checkout/checkout_page.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ All fixes applied successfully!")
print("✅ Using new CheckoutAddressWidget for inline display")
print("✅ Address will load and display automatically")
