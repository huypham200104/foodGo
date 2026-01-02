import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart'; // Import AppRoutes
import '../../services/screen_service.dart' as screen;
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/tier_system.dart';
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
                
                // Menu Items - 👈 Chỉ sử dụng routes có trong AppRoutes
                ProfileMenuItem(
                  icon: Icons.shopping_bag,
                  title: 'Đơn hàng của tôi',
                  subtitle: 'Xem lịch sử đặt hàng',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.orderHistory),
                ),
                
                ProfileMenuItem(
                  icon: Icons.local_offer,
                  title: 'Voucher',
                  subtitle: 'Xem voucher khả dụng',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.vouchers),
                ),
                
                ProfileMenuItem(
                  icon: Icons.card_membership,
                  title: 'Hạng thành viên',
                  subtitle: 'Xem các hạng thành viên',
                  onTap: () => _showTierListDialog(),
                ),
                
                ProfileMenuItem(
                  icon: Icons.location_on,
                  title: 'Địa chỉ giao hàng',
                  subtitle: 'Quản lý địa chỉ giao hàng',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.addressList), // 👈 Sửa thành addressList
                ),
                
                ProfileMenuItem(
                  icon: Icons.notifications,
                  title: 'Thông báo',
                  subtitle: 'Cài đặt thông báo',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.notification), // 👈 Sửa
                ),

                
                ProfileMenuItem(
                  icon: Icons.favorite,
                  title: 'Yêu thích',
                  subtitle: 'Món ăn yêu thích của bạn',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.favorites),
                ),
                
                ProfileMenuItem(
                  icon: Icons.help,
                  title: 'Trợ giúp & Hỗ trợ',
                  subtitle: 'FAQ, liên hệ hỗ trợ',
                  onTap: () => _showComingSoonDialog('Trợ giúp & Hỗ trợ'), // 👈 Temporary
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

  // 👈 Thêm dialog hiển thị danh sách tiers
  void _showTierListDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.card_membership,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hạng Thành Viên',
                        style: TextStyle(
                          fontSize: screen.ScreenService.mediumText,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Tier list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
                  itemCount: TierSystem.tiers.length,
                  itemBuilder: (context, index) {
                    final tier = TierSystem.tiers[index];
                    return _buildTierCard(tier);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard(TierConfig tier) {
    // Color mapping for tiers
    Color getTierColor() {
      switch (tier.name) {
        case 'New':
          return Colors.grey;
        case 'Bronze':
          return Color(0xFFCD7F32);
        case 'Silver':
          return Colors.grey.shade400;
        case 'Gold':
          return Color(0xFFFFD700);
        case 'Platinum':
          return Color(0xFFE5E4E2);
        default:
          return AppColors.primary;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: screen.ScreenService.mediumSpacing),
      padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: getTierColor().withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: getTierColor().withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier name and discount
          Row(
            children: [
              Icon(
                Icons.stars,
                color: getTierColor(),
                size: 24,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  tier.name,
                  style: TextStyle(
                    fontSize: screen.ScreenService.mediumText,
                    fontWeight: FontWeight.bold,
                    color: getTierColor(),
                  ),
                ),
              ),
              if (tier.discountPercentage > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '-${tier.discountPercentage.toInt()}%',
                    style: TextStyle(
                      fontSize: screen.ScreenService.smallText,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          // Points requirement
          Text(
            tier.maxPoints != null
                ? 'Yêu cầu: ${tier.minPoints} - ${tier.maxPoints} điểm'
                : 'Yêu cầu: ${tier.minPoints}+ điểm',
            style: TextStyle(
              fontSize: screen.ScreenService.smallText,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          // Benefits
          Text(
            'Quyền lợi:',
            style: TextStyle(
              fontSize: screen.ScreenService.smallText,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          ...tier.benefits.map((benefit) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        benefit,
                        style: TextStyle(
                          fontSize: screen.ScreenService.smallText - 1,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // 👈 Thêm dialog cho coming soon features
  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.construction, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Đang phát triển'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$feature sẽ được cập nhật trong phiên bản tiếp theo.',
              style: TextStyle(
                fontSize: screen.ScreenService.smallText,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cảm ơn bạn đã sử dụng FoodGo!',
                      style: TextStyle(
                        fontSize: screen.ScreenService.smallText - 1,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  // 👈 Thêm dialog về ứng dụng
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'FoodGo',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.restaurant,
          color: Colors.white,
          size: 32,
        ),
      ),
      applicationLegalese: '© 2024 FoodGo. Tất cả quyền được bảo lưu.',
      children: [
        SizedBox(height: 16),
        Text(
          'FoodGo là ứng dụng đặt món ăn trực tuyến, mang đến trải nghiệm đặt hàng thuận tiện và nhanh chóng.',
          style: TextStyle(
            fontSize: screen.ScreenService.smallText,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.email, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 8),
            Text(
              'support@foodgo.com',
              style: TextStyle(
                fontSize: screen.ScreenService.smallText,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 8),
            Text(
              '1900-1234',
              style: TextStyle(
                fontSize: screen.ScreenService.smallText,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
            SizedBox(width: 8),
            Text('Đăng xuất'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: TextStyle(
            fontSize: screen.ScreenService.smallText,
            color: AppColors.textSecondary,
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
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}


