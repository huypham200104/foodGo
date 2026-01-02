import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address_model.dart';
import '../core/theme/app_colors.dart';
import '../services/screen_service.dart' as screen;
import 'custom_input_field.dart';

class AddressFormWidget extends StatefulWidget {
  final AddressModel? address;
  final Function(AddressModel) onSave;
  final VoidCallback? onCancel;
  final String? userId; // Thêm userId parameter

  const AddressFormWidget({
    super.key,
    this.address,
    required this.onSave,
    this.onCancel,
    this.userId,
  });

  @override
  State<AddressFormWidget> createState() => AddressFormWidgetState();
}

class AddressFormWidgetState extends State<AddressFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _detailController = TextEditingController();
  final _cityController = TextEditingController();
  final _wardController = TextEditingController();
  final _districtController = TextEditingController(); // Thêm district controller
  final _phoneController = TextEditingController(); // Thêm phone controller
  bool _isDefault = false;
  bool _isScreenServiceInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isScreenServiceInitialized) {
      screen.ScreenService.init(context);
      _isScreenServiceInitialized = true;
    }
  }

  void _initializeData() {
    if (widget.address != null) {
      final address = widget.address!;
      _labelController.text = address.safeLabel;
      _detailController.text = address.safeDetail;
      _cityController.text = address.safeCity;
      _wardController.text = address.safeWard;
      _districtController.text = address.safeDistrict;
      _phoneController.text = address.safePhone;
      _isDefault = address.isDefault;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _detailController.dispose();
    _cityController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomInputField(
            controller: _labelController,
            labelText: 'Tên địa chỉ *',
            hintText: 'VD: Nhà, Công ty, Trường học...',
            prefixIcon: const Icon(Icons.label, color: AppColors.primary),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên địa chỉ';
              }
              return null;
            },
          ),
          SizedBox(height: screen.ScreenService.mediumSpacing),
          
          CustomInputField(
            controller: _cityController,
            labelText: 'Thành phố *',
            hintText: 'VD: Thành phố Hồ Chí Minh, Hà Nội...',
            prefixIcon: const Icon(Icons.location_city, color: AppColors.primary),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập thành phố';
              }
              return null;
            },
          ),
          SizedBox(height: screen.ScreenService.mediumSpacing),
          
          // District field
          CustomInputField(
            controller: _districtController,
            labelText: 'Quận/Huyện',
            hintText: 'VD: Quận 1, Huyện Củ Chi...',
            prefixIcon: const Icon(Icons.map, color: AppColors.primary),
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: screen.ScreenService.mediumSpacing),
          
          CustomInputField(
            controller: _wardController,
            labelText: 'Phường/Xã *',
            hintText: 'VD: Phường Bến Nghé, Xã Tân An...',
            prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập phường/xã';
              }
              return null;
            },
          ),
          SizedBox(height: screen.ScreenService.mediumSpacing),
          
          CustomInputField(
            controller: _detailController,
            labelText: 'Địa chỉ chi tiết *',
            hintText: 'Số nhà, tên đường, tòa nhà...',
            prefixIcon: const Icon(Icons.home, color: AppColors.primary),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập địa chỉ chi tiết';
              }
              return null;
            },
          ),
          SizedBox(height: screen.ScreenService.mediumSpacing),
          
          // Phone field
          CustomInputField(
            controller: _phoneController,
            labelText: 'Số điện thoại',
            hintText: 'VD: 0123456789',
            prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                // Validate phone number format if provided
                final phoneRegex = RegExp(r'^[0-9]{10,11}$');
                if (!phoneRegex.hasMatch(value.trim().replaceAll(' ', ''))) {
                  return 'Số điện thoại không hợp lệ';
                }
              }
              return null;
            },
          ),
          SizedBox(height: screen.ScreenService.mediumSpacing),
          
          _buildDefaultCheckbox(),
        ],
      ),
    );
  }

  Widget _buildDefaultCheckbox() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(screen.ScreenService.smallSpacing),
        border: Border.all(color: AppColors.textLight.withValues(alpha: 0.5)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screen.ScreenService.mediumSpacing,
        vertical: screen.ScreenService.smallSpacing / 2,
      ),
      child: Row(
        children: [
          Checkbox(
            value: _isDefault,
            onChanged: (value) => setState(() => _isDefault = value ?? false),
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          SizedBox(width: screen.ScreenService.smallSpacing),
          Expanded(
            child: Text(
              'Đặt làm địa chỉ mặc định',
              style: TextStyle(
                fontSize: screen.ScreenService.smallText,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_isDefault)
            Icon(
              Icons.star,
              color: AppColors.warning,
              size: screen.ScreenService.mediumSpacing,
            ),
        ],
      ),
    );
  }

  void saveAddress() {
    if (_formKey.currentState!.validate()) {
      // Lấy userId và cast explicit
      final String userId;
      final tempUserId = widget.userId ?? widget.address?.userId;
      // Try to fallback to currently authenticated Firebase user if parent didn't provide userId
      if (tempUserId == null || tempUserId.isEmpty) {
        final current = FirebaseAuth.instance.currentUser;
        if (current != null && current.uid.isNotEmpty) {
          debugPrint('AddressFormWidget: falling back to FirebaseAuth.currentUser.uid=${current.uid}');
          userId = current.uid;
        } else {
          _showError('Không tìm thấy thông tin người dùng');
          return;
        }
      } else {
        userId = tempUserId; // Safe assignment
      }

      // Validate và get other fields
      final labelText = _labelController.text.trim();
      if (labelText.isEmpty) {
        _showError('Vui lòng nhập tên địa chỉ');
        return;
      }

      final detailText = _detailController.text.trim();
      if (detailText.isEmpty) {
        _showError('Vui lòng nhập địa chỉ chi tiết');
        return;
      }

      final cityText = _cityController.text.trim();
      if (cityText.isEmpty) {
        _showError('Vui lòng nhập thành phố');
        return;
      }

      final wardText = _wardController.text.trim();
      if (wardText.isEmpty) {
        _showError('Vui lòng nhập phường/xã');
        return;
      }

      final address = AddressModel.fromFormData(
        id: widget.address?.id,
        userId: userId,               // Now guaranteed to be String
        label: labelText,
        name: labelText,
        detail: detailText,
        city: cityText,
        ward: wardText,
        district: _districtController.text.trim().isNotEmpty 
            ? _districtController.text.trim() 
            : null,
        phone: _phoneController.text.trim().isNotEmpty 
            ? _phoneController.text.trim() 
            : null,
        isDefault: _isDefault,
        latitude: widget.address?.latitude,
        longitude: widget.address?.longitude,
      );
      
      widget.onSave(address);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void reset() {
    _formKey.currentState?.reset();
    _labelController.clear();
    _detailController.clear();
    _cityController.clear();
    _wardController.clear();
    _districtController.clear();
    _phoneController.clear();
    setState(() => _isDefault = false);
  }
}

