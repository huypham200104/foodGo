import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart'; // Import AppRoutes
import '../../services/screen_service.dart' as screen;
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import 'widgets/profile_info_widget.dart';
import 'widgets/profile_menu_item.dart';
import 'widgets/profile_edit_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isScreenServiceInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isScreenServiceInitialized) {
      screen.ScreenService.init(context);
      _isScreenServiceInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Hồ sơ',
          style: TextStyle(
            fontSize: screen.ScreenService.largeText,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 64,
                    color: AppColors.textLight,
                  ),
                  SizedBox(height: screen.ScreenService.mediumSpacing),
                  Text(
                    'Chưa đăng nhập',
                    style: TextStyle(
                      fontSize: screen.ScreenService.mediumText,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Info Section
                ProfileInfoWidget(
                  user: user,
                  onTap: () => _showEditProfileDialog(user),
                ),
                
                SizedBox(height: screen.ScreenService.smallSpacing),
                
                // Menu Items
                ProfileMenuItem(
                  icon: Icons.shopping_bag,
                  title: 'Đơn hàng của tôi',
                  subtitle: 'Xem lịch sử đặt hàng',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.orderHistory),
                ),
                
                ProfileMenuItem(
                  icon: Icons.location_on,
                  title: 'Địa chỉ giao hàng',
                  subtitle: 'Quản lý địa chỉ giao hàng',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.addresses),
                ),
                
                ProfileMenuItem(
                  icon: Icons.payment,
                  title: 'Phương thức thanh toán',
                  subtitle: 'Thêm/sửa thông tin thanh toán',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.paymentMethods),
                ),
                
                ProfileMenuItem(
                  icon: Icons.favorite,
                  title: 'Yêu thích',
                  subtitle: 'Món ăn yêu thích của bạn',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.favorites),
                ),
                
                ProfileMenuItem(
                  icon: Icons.notifications,
                  title: 'Thông báo',
                  subtitle: 'Cài đặt thông báo',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                ),
                
                ProfileMenuItem(
                  icon: Icons.help,
                  title: 'Trợ giúp & Hỗ trợ',
                  subtitle: 'FAQ, liên hệ hỗ trợ',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.help),
                ),
                
                ProfileMenuItem(
                  icon: Icons.info,
                  title: 'Về ứng dụng',
                  subtitle: 'Thông tin phiên bản, điều khoản',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                ),
                
                ProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  iconColor: AppColors.error,
                  onTap: () => _showLogoutDialog(),
                ),
                
                SizedBox(height: screen.ScreenService.largeSpacing),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfileEditDialog(
        user: user,
        onSaved: _updateUserProfile,
      ),
    );
  }

  Future<void> _updateUserProfile(UserModel updatedUser) async {
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .updateUserInfoAndSave(updatedUser);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật thông tin: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
