import 'package:flutter/material.dart';
import '../../../models/address_model.dart';
import '../../../widgets/custom_dialog.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/address_form_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;

class AddressFormDialog extends StatefulWidget {
  final AddressModel? address;
  final Function(AddressModel) onSaved;

  const AddressFormDialog({
    super.key,
    this.address,
    required this.onSaved,
  });

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final GlobalKey<AddressFormWidgetState> _formKey = GlobalKey<AddressFormWidgetState>();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: widget.address == null ? 'Thêm địa chỉ mới' : 'Chỉnh sửa địa chỉ',
      content: AddressFormWidget(
        key: _formKey,
        address: widget.address,
        onSave: _handleSave,
      ),
      actions: [
        CustomButton(
          text: 'Hủy',
          type: ButtonType.text,
          onPressed: () => Navigator.pop(context),
        ),
        SizedBox(width: screen.ScreenService.smallSpacing),
        CustomButton(
          text: widget.address == null ? 'Thêm địa chỉ' : 'Cập nhật',
          type: ButtonType.primary,
          isLoading: _isSaving,
          onPressed: _handleSaveButton,
          icon: Icon(
            widget.address == null ? Icons.add : Icons.update,
            size: 18,
          ),
        ),
      ],
    );
  }

  void _handleSaveButton() {
    _formKey.currentState?.saveAddress();
  }

  void _handleSave(AddressModel address) async {
    setState(() => _isSaving = true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      widget.onSaved(address);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.address == null 
                  ? 'Đã thêm địa chỉ thành công!' 
                  : 'Đã cập nhật địa chỉ thành công!',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

