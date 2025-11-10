import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/screen_service.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

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
          'Thông báo',
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
              Icons.settings_outlined,
              color: AppColors.textSecondary,
              size: ScreenService.isSmallScreen ? 20 : 24,
            ),
            onPressed: () {
              // Navigate to notification settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cài đặt thông báo'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            tooltip: 'Cài đặt thông báo',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.borderLight,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            );
          }
          
          if (snapshot.hasError) {
            return _ErrorState(
              onRetry: () {
                // Trigger rebuild
                (context as Element).reassemble();
              },
            );
          }
          
          final docs = snapshot.data?.docs ?? const [];
          if (docs.isEmpty) {
            return _EmptyState();
          }
          
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              // Refresh logic here
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                vertical: ScreenService.smallSpacing,
                horizontal: ScreenService.mediumSpacing,
              ),
              itemCount: docs.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppColors.borderLight,
                indent: 60, // Space for avatar
              ),
              itemBuilder: (context, index) {
                final n = docs[index].data();
                return _NotificationTile(
                  id: docs[index].id,
                  avatar: n['avatar'] ?? '',
                  title: n['title'] ?? '',
                  subtitle: n['subtitle'] ?? '',
                  timestamp: n['createdAt']?.toDate() ?? DateTime.now(),
                  isNew: n['isNew'] == true,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenService.init(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenService.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ScreenService.isSmallScreen ? 80 : 96,
              height: ScreenService.isSmallScreen ? 80 : 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: ScreenService.isSmallScreen ? 40 : 48,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            SizedBox(height: ScreenService.mediumSpacing),
            Text(
              'Chưa có thông báo!',
              style: TextStyle(
                fontSize: ScreenService.largeText,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: ScreenService.smallSpacing),
            Text(
              'Khi có thông báo mới, chúng sẽ xuất hiện ở đây.\nBạn có thể bật thông báo trong cài đặt.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ScreenService.smallText,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: ScreenService.largeSpacing),
            SizedBox(
              width: ScreenService.isSmallScreen ? 200 : 240,
              height: ScreenService.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Đang mở cài đặt thông báo...'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: Icon(
                  Icons.settings_outlined,
                  size: ScreenService.isSmallScreen ? 18 : 20,
                ),
                label: const Text('Cài đặt thông báo'),
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
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    ScreenService.init(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenService.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ScreenService.isSmallScreen ? 64 : 80,
              color: AppColors.error,
            ),
            SizedBox(height: ScreenService.mediumSpacing),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: ScreenService.largeText,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: ScreenService.smallSpacing),
            Text(
              'Không thể tải danh sách thông báo.\nVui lòng thử lại.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ScreenService.smallText,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: ScreenService.largeSpacing),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(0, ScreenService.buttonHeight),
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
}

class _NotificationTile extends StatelessWidget {
  final String id;
  final String avatar;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool isNew;
  
  const _NotificationTile({
    required this.id,
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.isNew,
  });

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenService.init(context);
    
    return Dismissible(
      key: ValueKey(id),
      background: _ActionBackground(
        alignment: Alignment.centerLeft,
        color: AppColors.error,
        icon: Icons.delete_outline,
        label: 'Xóa',
      ),
      secondaryBackground: _ActionBackground(
        alignment: Alignment.centerRight,
        color: AppColors.success,
        icon: Icons.check_circle_outline,
        label: 'Đánh dấu đã đọc',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Delete notification
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(
                'Xóa thông báo',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: Text(
                'Bạn có chắc chắn muốn xóa thông báo này?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Hủy',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Xóa',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ) ?? false;
        } else {
          // Mark as read
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã đánh dấu đã đọc'),
              backgroundColor: AppColors.success,
            ),
          );
          return false;
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: ScreenService.smallSpacing / 2),
        decoration: BoxDecoration(
          color: isNew ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isNew ? AppColors.primary.withOpacity(0.2) : AppColors.borderLight,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: ScreenService.mediumSpacing,
            vertical: ScreenService.smallSpacing / 2,
          ),
          leading: CircleAvatar(
            radius: ScreenService.isSmallScreen ? 20 : 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: avatar.isNotEmpty ? AssetImage(avatar) as ImageProvider : null,
            child: avatar.isEmpty
                ? Icon(
                    Icons.notifications,
                    color: AppColors.primary,
                    size: ScreenService.isSmallScreen ? 16 : 20,
                  )
                : null,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title.isNotEmpty ? title : 'Thông báo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ScreenService.mediumText,
                    fontWeight: isNew ? FontWeight.w600 : FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isNew) ...[
                SizedBox(width: ScreenService.smallSpacing),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'MỚI',
                    style: TextStyle(
                      fontSize: ScreenService.isSmallScreen ? 9 : 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle.isNotEmpty) ...[
                SizedBox(height: ScreenService.smallSpacing / 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: ScreenService.smallText,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
              SizedBox(height: ScreenService.smallSpacing / 2),
              Text(
                _formatTimestamp(timestamp),
                style: TextStyle(
                  fontSize: ScreenService.isSmallScreen ? 11 : 12,
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary.withOpacity(0.5),
            size: ScreenService.isSmallScreen ? 18 : 20,
          ),
          onTap: () {
            // Handle notification tap
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Xem chi tiết: $title'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionBackground extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  const _ActionBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    ScreenService.init(context);
    
    return Container(
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: ScreenService.mediumSpacing),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: ScreenService.isSmallScreen ? 18 : 20,
          ),
          SizedBox(width: ScreenService.smallSpacing),
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenService.smallText,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}


