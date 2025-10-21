import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_confirm_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isVietnamese = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tài Khoản',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header với background gradient
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E3A8A),
                        Color(0xFF3B82F6),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background images
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Image.asset(
                          'assets/doAn/pizza_HaiSan.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Image.asset(
                          'assets/doAn/kemLy.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // User info
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Avatar
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: authProvider.isLoggedIn
                                  ? CircleAvatar(
                                      backgroundImage: authProvider.currentUser?.avatarUrl != null
                                          ? NetworkImage(authProvider.currentUser!.avatarUrl)
                                          : null,
                                      child: authProvider.currentUser?.avatarUrl == null
                                          ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                          : null,
                                    )
                                  : const Icon(Icons.person, size: 40, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              authProvider.isLoggedIn 
                                  ? (authProvider.currentUser?.name ?? 'User')
                                  : 'Guest User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authProvider.isLoggedIn 
                                  ? 'Member | ${authProvider.currentUser?.rewardPoints ?? 0} Điểm'
                                  : 'Guest | 0 Điểm',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Barcode
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '3 1117 01320 6375',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Account options
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tài khoản của tôi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Thông Tin Cá Nhân',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.card_giftcard_outlined,
                        title: 'Phần Thưởng',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.location_on_outlined,
                        title: 'Sổ Địa Chỉ',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.history,
                        title: 'Lịch Sử Đơn Hàng',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.favorite_outline,
                        title: 'Món Yêu Thích',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                
                // General information section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin chung',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        icon: Icons.store_outlined,
                        title: 'Danh Sách Cửa Hàng',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.newspaper_outlined,
                        title: 'Tin Tức',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.policy_outlined,
                        title: 'Chính Sách',
                        onTap: () {},
                      ),
                      
                      // Language selector
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ngôn Ngữ',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => _isVietnamese = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _isVietnamese ? AppColors.primary : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'VN',
                                      style: TextStyle(
                                        color: _isVietnamese ? Colors.white : Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => setState(() => _isVietnamese = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: !_isVietnamese ? AppColors.primary : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'EN',
                                      style: TextStyle(
                                        color: !_isVietnamese ? Colors.white : Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const Divider(),
                      
                      // Action buttons
                      _buildActionButton(
                        'Đổi Mật Khẩu',
                        onTap: () {
                          _showChangePasswordDialog(context);
                        },
                      ),
                      _buildActionButton(
                        'Xóa Tài Khoản',
                        onTap: () {
                          _showDeleteAccountDialog(context);
                        },
                        isDestructive: true,
                      ),
                      _buildActionButton(
                        'Đăng Xuất',
                        onTap: () {
                          if (authProvider.isLoggedIn) {
                            _showLogoutDialog(context);
                          }
                        },
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Branding section
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo/logo_light.jpg',
                        height: 40,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '15 Lê Thánh Tôn, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh, Việt Nam',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildActionButton(String title, {required VoidCallback onTap, bool isDestructive = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.centerLeft,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: isDestructive ? Colors.red : AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đổi mật khẩu'),
          content: const Text('Tính năng đổi mật khẩu đang được phát triển'),
          actions: [
            CustomConfirmButtonStyles.outline(
              text: 'Hủy',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            CustomConfirmButtonStyles.primary(
              text: 'OK',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa tài khoản'),
          content: const Text('Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác.'),
          actions: [
            CustomConfirmButtonStyles.outline(
              text: 'Hủy',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            CustomConfirmButtonStyles.danger(
              text: 'Xóa',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng xóa tài khoản đang được phát triển')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            CustomConfirmButtonStyles.outline(
              text: 'Hủy',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            CustomConfirmButtonStyles.warning(
              text: 'Đăng xuất',
              onPressed: () {
                Navigator.pop(context);
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pop(context); // Close profile page
              },
            ),
          ],
        );
      },
    );
  }
}
