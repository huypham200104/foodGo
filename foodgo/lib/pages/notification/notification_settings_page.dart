import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/notification_settings_provider.dart';
import '../../services/screen_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    // Load settings khi vào trang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationSettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenService.init(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: ScreenService.isSmallScreen ? 20 : 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Quay lại',
        ),
        title: Text(
          'Cài đặt thông báo',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: ScreenService.isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppColors.textSecondary,
              size: ScreenService.isSmallScreen ? 20 : 24,
            ),
            onPressed: () => _showResetDialog(context),
            tooltip: 'Reset về mặc định',
          ),
        ],
      ),
      body: Consumer<NotificationSettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Có lỗi xảy ra',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadSettings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final settings = provider.settings;

          return ListView(
            padding: EdgeInsets.all(ScreenService.isSmallScreen ? 12 : 16),
            children: [
              // Master switch - Bật/tắt tất cả thông báo
              _buildMasterSwitch(context, provider, settings.isEnabled),
              
              const SizedBox(height: 24),
              
              // Loại thông báo
              _buildSectionTitle('Loại thông báo'),
              const SizedBox(height: 8),
              _buildSettingCard(
                context,
                icon: Icons.shopping_bag_outlined,
                title: 'Cập nhật đơn hàng',
                subtitle: 'Nhận thông báo về trạng thái đơn hàng',
                value: settings.orderUpdates,
                enabled: settings.isEnabled,
                onChanged: (value) => provider.updateOrderUpdates(value),
              ),
              const SizedBox(height: 8),
              _buildSettingCard(
                context,
                icon: Icons.local_offer_outlined,
                title: 'Khuyến mãi & Ưu đãi',
                subtitle: 'Nhận thông báo về các chương trình khuyến mãi',
                value: settings.promotions,
                enabled: settings.isEnabled,
                onChanged: (value) => provider.updatePromotions(value),
              ),
              const SizedBox(height: 8),
              _buildSettingCard(
                context,
                icon: Icons.chat_bubble_outline,
                title: 'Tin nhắn chat',
                subtitle: 'Nhận thông báo khi có tin nhắn mới',
                value: settings.chatMessages,
                enabled: settings.isEnabled,
                onChanged: (value) => provider.updateChatMessages(value),
              ),
              const SizedBox(height: 8),
              _buildSettingCard(
                context,
                icon: Icons.restaurant_outlined,
                title: 'Cập nhật nhà hàng',
                subtitle: 'Thông báo từ nhà hàng bạn theo dõi',
                value: settings.restaurantUpdates,
                enabled: settings.isEnabled,
                onChanged: (value) => provider.updateRestaurantUpdates(value),
              ),
              const SizedBox(height: 8),
              _buildSettingCard(
                context,
                icon: Icons.stars_outlined,
                title: 'Điểm thưởng',
                subtitle: 'Nhận thông báo về điểm thưởng và phần quà',
                value: settings.rewardPoints,
                enabled: settings.isEnabled,
                onChanged: (value) => provider.updateRewardPoints(value),
              ),
              const SizedBox(height: 8),
              _buildSettingCard(
                context,
                icon: Icons.system_update_outlined,
                title: 'Cập nhật ứng dụng',
                subtitle: 'Thông báo khi có phiên bản mới',
                value: settings.appUpdates,
                enabled: settings.isEnabled,
                onChanged: (value) => provider.updateAppUpdates(value),
              ),
              
              const SizedBox(height: 24),
              
              // Cài đặt âm thanh & rung
              _buildSectionTitle('Hiệu ứng'),
              const SizedBox(height: 8),
              _buildSettingCard(
                context,
                icon: Icons.volume_up_outlined,
                title: 'Âm thanh',
                subtitle: 'Phát âm thanh khi có thông báo',
                value: settings.soundEnabled,
                enabled: settings.isEnabled,
                onChanged: (value) => provider.updateSoundEnabled(value),
              ),
              const SizedBox(height: 8),
              _buildSettingCard(
                context,
                icon: Icons.vibration,
                title: 'Rung',
                subtitle: 'Rung thiết bị khi có thông báo',
                value: settings.vibrationEnabled,
                enabled: settings.isEnabled,
                onChanged: (value) => provider.updateVibrationEnabled(value),
              ),
              
              const SizedBox(height: 24),
              
              // Thông tin bổ sung
              _buildInfoCard(context),
              
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMasterSwitch(
    BuildContext context,
    NotificationSettingsProvider provider,
    bool isEnabled,
  ) {
    return Container(
      padding: EdgeInsets.all(ScreenService.isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEnabled 
                  ? AppColors.primary.withValues(alpha: 0.1) 
                  : AppColors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_active,
              color: isEnabled ? AppColors.primary : AppColors.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông báo',
                  style: TextStyle(
                    fontSize: ScreenService.isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEnabled 
                      ? 'Đang bật - Bạn sẽ nhận thông báo' 
                      : 'Đang tắt - Bạn sẽ không nhận thông báo',
                  style: TextStyle(
                    fontSize: ScreenService.isSmallScreen ? 13 : 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) => provider.updateIsEnabled(value),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ScreenService.isSmallScreen ? 14 : 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required Function(bool) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        enabled: enabled,
        leading: Icon(
          icon,
          color: enabled 
              ? (value ? AppColors.primary : AppColors.textSecondary)
              : AppColors.textSecondary.withValues(alpha: 0.5),
          size: ScreenService.isSmallScreen ? 22 : 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: ScreenService.isSmallScreen ? 15 : 16,
            fontWeight: FontWeight.w500,
            color: enabled 
                ? AppColors.textPrimary 
                : AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: ScreenService.isSmallScreen ? 12 : 13,
            color: enabled 
                ? AppColors.textSecondary 
                : AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: AppColors.primary,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ScreenService.isSmallScreen ? 12 : 16,
          vertical: ScreenService.isSmallScreen ? 4 : 8,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenService.isSmallScreen ? 14 : 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: ScreenService.isSmallScreen ? 20 : 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lưu ý',
                  style: TextStyle(
                    fontSize: ScreenService.isSmallScreen ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bạn có thể tùy chỉnh các loại thông báo muốn nhận. Tắt thông báo có thể khiến bạn bỏ lỡ các ưu đãi hấp dẫn và cập nhật quan trọng về đơn hàng.',
                  style: TextStyle(
                    fontSize: ScreenService.isSmallScreen ? 12 : 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset cài đặt'),
        content: const Text(
          'Bạn có chắc muốn reset tất cả cài đặt về mặc định? '
          'Tất cả các loại thông báo sẽ được bật lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                await context.read<NotificationSettingsProvider>().resetToDefault();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Đã reset về cài đặt mặc định'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
