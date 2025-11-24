import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/address_model.dart';
import '../../core/theme/app_colors.dart';
import '../../services/screen_service.dart' as screen;
import '../../services/address_service.dart'; // Use AddressService instead
import 'widgets/address_form_dialog.dart';
import 'widgets/address_item_tile.dart';

class AddressManagementPage extends StatefulWidget {
  final bool isSelectMode;
  final Function(AddressModel)? onAddressSelected;

  const AddressManagementPage({
    super.key,
    this.isSelectMode = false,
    this.onAddressSelected,
  });

  @override
  State<AddressManagementPage> createState() => _AddressManagementPageState();
}

class _AddressManagementPageState extends State<AddressManagementPage> {
  List<AddressModel> addresses = [];
  bool isLoading = true;
  String? selectedAddressId;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screen.ScreenService.init(context);
  }

  Future<void> _loadAddresses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.id == null) return;

    try {
      final userAddresses = await AddressService.getUserAddresses(
        authProvider.currentUser!.id
      );

      setState(() {
        addresses = userAddresses;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelectMode ? 'Chọn địa chỉ' : 'Quản lý địa chỉ'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: _showAddAddressDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : addresses.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
                        itemCount: addresses.length,
                        separatorBuilder: (_, __) => SizedBox(height: screen.ScreenService.smallSpacing),
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          return AddressItemTile(
                            address: address,
                            isSelected: widget.isSelectMode && selectedAddressId == address.id,
                            onTap: widget.isSelectMode
                                ? () => _selectAddress(address)
                                : null,
                            onEdit: () => _showEditAddressDialog(address),
                            onDelete: () => _deleteAddress(address.id),
                          );
                        },
                      ),
                    ),
                    if (widget.isSelectMode && selectedAddressId != null)
                      _buildSelectButton(),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: screen.ScreenService.largeSpacing * 2,
              color: AppColors.textLight,
            ),
            SizedBox(height: screen.ScreenService.mediumSpacing),
            Text(
              'Chưa có địa chỉ nào',
              style: TextStyle(
                fontSize: screen.ScreenService.mediumText,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: screen.ScreenService.smallSpacing),
            Text(
              'Thêm địa chỉ để tiếp tục',
              style: TextStyle(
                fontSize: screen.ScreenService.smallText,
                color: AppColors.textLight,
              ),
            ),
            SizedBox(height: screen.ScreenService.mediumSpacing),
            ElevatedButton.icon(
              onPressed: _showAddAddressDialog,
              icon: const Icon(Icons.add),
              label: const Text('Thêm địa chỉ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectButton() {
    return Container(
      padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: screen.ScreenService.buttonHeight,
        child: ElevatedButton(
          onPressed: () {
            final selectedAddress = addresses.firstWhere((a) => a.id == selectedAddressId);
            widget.onAddressSelected?.call(selectedAddress);
            Navigator.pop(context, selectedAddress);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
            ),
          ),
          child: Text(
            'Chọn địa chỉ này',
            style: TextStyle(
              fontSize: screen.ScreenService.mediumText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _selectAddress(AddressModel address) {
    setState(() {
      selectedAddressId = address.id;
    });
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AddressFormDialog(
        onSaved: (address) {
          _saveAddress(address);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditAddressDialog(AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AddressFormDialog(
        address: address,
        onSaved: (updatedAddress) {
          _updateAddress(updatedAddress);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _saveAddress(AddressModel address) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Create new address with userId
      final newAddress = address.copyWith(
        userId: authProvider.currentUser!.id,
      );
      
      await AddressService.addAddress(newAddress);
      _loadAddresses();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm địa chỉ thành công'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi thêm địa chỉ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _updateAddress(AddressModel address) async {
    try {
      await AddressService.updateAddress(address);
      
      _loadAddresses();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật địa chỉ thành công'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật địa chỉ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AddressService.deleteAddress(addressId);
        
        _loadAddresses();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa địa chỉ thành công'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa địa chỉ: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}