import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/address_model.dart';
import '../../../services/screen_service.dart' as screen;

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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      // Edit mode
      final address = widget.address!;
      _nameController.text = address.name ?? '';
      _phoneController.text = address.phone ?? '';
      _addressController.text = address.detail ?? address.fullAddress;
      _noteController.text = address.note ?? '';
      _isDefault = address.isDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tên địa chỉ
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên địa chỉ',
                    hintText: 'Nhà, Văn phòng, ...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên địa chỉ';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: screen.ScreenService.mediumSpacing),
                
                // Số điện thoại
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại',
                    hintText: '0987654321',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (value.length < 10) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: screen.ScreenService.mediumSpacing),
                
                // Địa chỉ chi tiết
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ chi tiết',
                    hintText: 'Số nhà, tên đường, phường/xã, quận/huyện, thành phố',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập địa chỉ chi tiết';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: screen.ScreenService.mediumSpacing),
                
                // Ghi chú
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú (tùy chọn)',
                    hintText: 'Ghi chú cho shipper...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
                
                SizedBox(height: screen.ScreenService.smallSpacing),
                
                // Đặt làm địa chỉ mặc định
                CheckboxListTile(
                  value: _isDefault,
                  onChanged: (value) {
                    setState(() {
                      _isDefault = value ?? false;
                    });
                  },
                  title: Text(
                    'Đặt làm địa chỉ mặc định',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: screen.ScreenService.smallText,
                    ),
                  ),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
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
          onPressed: _saveAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final address = AddressModel(
        id: widget.address?.id ?? '',
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        detail: _addressController.text.trim(),
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        isDefault: _isDefault,
        userId: widget.address?.userId,
      );
      
      Navigator.pop(context);
      widget.onSaved(address);
    }
  }
}