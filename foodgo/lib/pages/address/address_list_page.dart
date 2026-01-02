import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../services/screen_service.dart' as screen;
import '../../providers/auth_provider.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';
import 'widgets/address_card.dart';
import 'widgets/add_address_dialog.dart';
import '../../services/screen_service.dart';

class AddressListPage extends StatefulWidget {
  final bool selectMode;
  final Function(AddressModel)? onAddressSelected;

  const AddressListPage({
    super.key,
    this.selectMode = false,
    this.onAddressSelected,
  });

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  List<AddressModel> _addresses = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription<List<AddressModel>>? _addressesSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToAddresses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screen.ScreenService.init(context);
  }

  @override
  void dispose() {
    _addressesSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToAddresses() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      
      if (userId != null) {
        setState(() {
          _isLoading = true;
          _error = null;
        });

        _addressesSubscription = AddressService.getUserAddressesStream(userId)
            .listen(
          (addresses) {
            if (mounted) {
              setState(() {
                _addresses = addresses;
                _isLoading = false;
                _error = null;
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _error = 'Lỗi khi tải danh sách địa chỉ: $error';
                _isLoading = false;
              });
            }
          },
        );
      } else {
        setState(() {
          _error = 'Vui lòng đăng nhập để xem địa chỉ';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi kết nối: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshAddresses() async {
    _addressesSubscription?.cancel();
    _subscribeToAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.selectMode ? 'Chọn địa chỉ' : 'Danh sách địa chỉ'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: widget.selectMode ? [] : [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => _showAddAddressDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refreshAddresses,
        child: _buildBody(),
      ),
      floatingActionButton: widget.selectMode ? null : FloatingActionButton(
        onPressed: () => _showAddAddressDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_addresses.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      itemCount: _addresses.length,
      separatorBuilder: (context, index) => SizedBox(
        height: screen.ScreenService.smallSpacing,
      ),
      itemBuilder: (context, index) {
        final address = _addresses[index];
        
        if (widget.selectMode) {
          // 👈 Simple card for select mode
          return _buildSelectModeAddressCard(address);
        } else {
          // 👈 Full featured card for normal mode
          return AddressCard(
            address: address,
            onEdit: () => _editAddress(address),
            onDelete: () => _deleteAddress(address),
            isSelected: address.isDefault,
            showActions: true,
          );
        }
      },
    );
  }

  Widget _buildSelectModeAddressCard(AddressModel address) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _selectAddress(address),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            address.displayName,
                            style: TextStyle(
                              fontSize: screen.ScreenService.mediumText,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (address.isDefault)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Mặc định',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screen.ScreenService.smallText - 1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: screen.ScreenService.smallSpacing),
                    if (address.safePhone.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                          SizedBox(width: 8),
                          Text(
                            address.safePhone,
                            style: TextStyle(
                              fontSize: screen.ScreenService.smallText,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address.displayAddress,
                            style: TextStyle(
                              fontSize: screen.ScreenService.smallText,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: screen.ScreenService.smallSpacing),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screen.ScreenService.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: screen.ScreenService.mediumSpacing),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: screen.ScreenService.largeText,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: screen.ScreenService.smallSpacing),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screen.ScreenService.smallText,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: screen.ScreenService.largeSpacing),
            ElevatedButton.icon(
              onPressed: _refreshAddresses,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(0, screen.ScreenService.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screen.ScreenService.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screen.ScreenService.isSmallScreen ? 80 : 96,
              height: screen.ScreenService.isSmallScreen ? 80 : 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off,
                size: screen.ScreenService.isSmallScreen ? 40 : 48,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: screen.ScreenService.mediumSpacing),
            Text(
              'Chưa có địa chỉ giao hàng',
              style: TextStyle(
                fontSize: screen.ScreenService.largeText,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: screen.ScreenService.smallSpacing),
            Text(
              'Thêm địa chỉ để có thể đặt hàng và nhận giao hàng tận nơi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screen.ScreenService.smallText,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: screen.ScreenService.largeSpacing),
            SizedBox(
              width: screen.ScreenService.isSmallScreen ? 200 : 240,
              height: screen.ScreenService.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: _showAddAddressDialog,
                icon: Icon(
                  Icons.add,
                  size: screen.ScreenService.isSmallScreen ? 18 : 20,
                ),
                label: const Text('Thêm địa chỉ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddAddressDialog(
        onSaved: _addNewAddress,
      ),
    );
  }

  Future<void> _addNewAddress(AddressModel address) async {
    // AddAddressDialog already saves to Firebase, just refresh the list
    await _refreshAddresses();
  }

  void _selectAddress(AddressModel address) {
    if (widget.selectMode) {
      if (widget.onAddressSelected != null) {
        widget.onAddressSelected!(address);
      }
      Navigator.pop(context, address);  // Return selected address
    }
  }

  void _editAddress(AddressModel address) async {
    // TODO: Implement edit address functionality
    // Có thể navigate đến address form để edit
    try {
      // Placeholder - navigate to address management với edit mode
      final result = await Navigator.pushNamed(
        context,
        AppRoutes.addressManagement,
        arguments: {
          'editMode': true,
          'address': address,
        },
      );
      
      if (result == true) {
        // Refresh if address was edited
        await _refreshAddresses();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chỉnh sửa địa chỉ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _deleteAddress(AddressModel address) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: AppColors.error),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc chắn muốn xóa địa chỉ này?',
              style: TextStyle(
                fontSize: screen.ScreenService.smallText,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: screen.ScreenService.smallText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    address.displayAddress,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: screen.ScreenService.smallText - 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AddressService.deleteAddress(address.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã xóa địa chỉ'),
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

  // Method để set address làm mặc định
  Future<void> _setAsDefault(AddressModel address) async {
    try {
      await AddressService.setDefaultAddress(address.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã đặt làm địa chỉ mặc định'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đặt địa chỉ mặc định: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}


