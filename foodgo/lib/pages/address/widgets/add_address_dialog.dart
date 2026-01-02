import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/address_model.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../services/address_service.dart';
import '../../../widgets/address_form_widget.dart';

class AddAddressDialog extends StatefulWidget {
  final AddressModel? address; // Null for add, non-null for edit
  final Function(AddressModel) onSaved;

  const AddAddressDialog({
    super.key,
    this.address,
    required this.onSaved,
  });

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final GlobalKey<AddressFormWidgetState> _formKey = GlobalKey<AddressFormWidgetState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screen.ScreenService.init(context);
    final isEdit = widget.address != null;
    
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        isEdit ? 'Sửa địa chỉ' : 'Thêm địa chỉ mới',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: AddressFormWidget(
            key: _formKey,
            address: widget.address,
            onSave: _handleSave,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading 
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(isEdit ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }

  void _handleSave(AddressModel address) {
    // This will be called by AddressFormWidget when form is valid
    _saveAddressToFirebase(address);
  }

  void _saveAddress() {
    // Trigger the form save
    _formKey.currentState?.saveAddress();
  }

  Future<void> _saveAddressToFirebase(AddressModel address) async {
    setState(() => _isLoading = true);

    try {
      if (widget.address == null) {
        // Add new address
        await AddressService.addAddress(address);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm địa chỉ thành công'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // Update existing address
        await AddressService.updateAddress(address);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã cập nhật địa chỉ thành công'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
      
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved(address);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
