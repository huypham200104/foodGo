import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/screen_service.dart' as screen;
import '../../../services/cloudinary_service.dart';
import '../../../models/user_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_dialog.dart';
import 'avatar_upload_widget.dart';
import 'image_picker_options.dart';
import 'profile_form_fields.dart';
import 'user_stats_section.dart';

class ProfileEditDialog extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onSaved;

  const ProfileEditDialog({
    super.key,
    required this.user,
    required this.onSaved,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  File? _selectedImage;
  String? _uploadedImageUrl;
  String? _currentImagePublicId;
  bool _isUploading = false;
  bool _isSaving = false;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _nameController.text = widget.user.name;
    _phoneController.text = widget.user.phone;
    _emailController.text = widget.user.email;
    _uploadedImageUrl = widget.user.avatarUrl;
    
    if (widget.user.avatarUrl.isNotEmpty && widget.user.avatarUrl.contains('cloudinary.com')) {
      _currentImagePublicId = _extractPublicIdFromUrl(widget.user.avatarUrl);
    }
  }

  String? _extractPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex != -1 && uploadIndex + 2 < pathSegments.length) {
        final fileName = pathSegments.last;
        final publicId = pathSegments.sublist(uploadIndex + 2).join('/');
        return publicId.replaceAll('.${fileName.split('.').last}', '');
      }
    } catch (e) {
      print('Error extracting public_id: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Chỉnh sửa thông tin',
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar section
            AvatarUploadWidget(
              currentAvatarUrl: _uploadedImageUrl,
              selectedImage: _selectedImage,
              isUploading: _isUploading,
              onTap: _showImagePickerOptions,
            ),
            SizedBox(height: screen.ScreenService.mediumSpacing),
            
            // Form fields
            ProfileFormFields(
              nameController: _nameController,
              phoneController: _phoneController,
              emailController: _emailController,
            ),
            
            SizedBox(height: screen.ScreenService.mediumSpacing),
            
            // User stats section
            UserStatsSection(user: widget.user),
          ],
        ),
      ),
      actions: [
        CustomButton(
          text: 'Hủy',
          type: ButtonType.text,
          onPressed: () => Navigator.pop(context),
        ),
        SizedBox(width: screen.ScreenService.smallSpacing),
        CustomButton(
          text: 'Lưu thay đổi',
          type: ButtonType.primary,
          isLoading: _isSaving,
          onPressed: _saveProfile,
          icon: const Icon(Icons.save, size: 18),
        ),
      ],
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screen.ScreenService.mediumSpacing),
        ),
      ),
      builder: (context) {
        return ImagePickerOptions(
          onCamera: () => _pickImage(ImageSource.camera),
          onGallery: () => _pickImage(ImageSource.gallery),
          onRemove: (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) || _selectedImage != null
              ? _removeImage
              : null,
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _uploadImageToCloudinary();
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi chọn ảnh: $e');
    }
  }

  void _removeImage() {
    Navigator.pop(context);
    setState(() {
      _selectedImage = null;
      _uploadedImageUrl = '';
      _currentImagePublicId = null;
    });
  }

  Future<void> _uploadImageToCloudinary() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      if (_currentImagePublicId != null) {
        await CloudinaryService.deleteImage(_currentImagePublicId!);
      }

      final result = await CloudinaryService.uploadImage(
        _selectedImage!,
        folder: 'foodgo_avatars',
      );

      if (result != null) {
        setState(() {
          _uploadedImageUrl = result['secure_url'];
          _currentImagePublicId = result['public_id'];
        });
        _showSuccessSnackBar('Tải ảnh lên thành công!');
      } else {
        throw Exception('Upload failed: No result returned');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi tải ảnh lên: $e');
      setState(() {
        _selectedImage = null;
      });
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isUploading) {
      _showErrorSnackBar('Vui lòng chờ ảnh tải lên xong');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedUser = widget.user.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarUrl: _uploadedImageUrl ?? '',
        updatedAt: DateTime.now(),
      );

      widget.onSaved(updatedUser);
      
      if (mounted) {
        Navigator.pop(context);
        _showSuccessSnackBar('Cập nhật thông tin thành công!');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi lưu thông tin: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}