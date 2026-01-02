import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/screen_service.dart' as screen;
import '../../services/reward_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/reward_model.dart';
import 'package:intl/intl.dart';

class RewardsListPage extends StatefulWidget {
  const RewardsListPage({super.key});

  @override
  State<RewardsListPage> createState() => _RewardsListPageState();
}

class _RewardsListPageState extends State<RewardsListPage> {
  RewardModel? _reward;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isScreenServiceInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isScreenServiceInitialized) {
      screen.ScreenService.init(context);
      _isScreenServiceInitialized = true;
      _loadReward();
    }
  }

  Future<void> _loadReward() async {
    try {
      debugPrint('🔍 [RewardsListPage] _loadReward() started');
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      debugPrint('👤 [RewardsListPage] Current user: ${user?.id ?? "NULL"}');
      debugPrint('👤 [RewardsListPage] User name: ${user?.name ?? "NULL"}');
      debugPrint('👤 [RewardsListPage] User email: ${user?.email ?? "NULL"}');
      
      if (user == null) {
        debugPrint('❌ [RewardsListPage] User is null, cannot load reward');
        setState(() {
          _errorMessage = 'Vui lòng đăng nhập để xem phần thưởng';
          _isLoading = false;
        });
        return;
      }
      
      debugPrint('🔄 [RewardsListPage] Calling RewardService.getUserReward(${user.id})');
      final reward = await RewardService.getUserReward(user.id);
      
      if (reward == null) {
        debugPrint('⚠️  [RewardsListPage] Reward is NULL for userId: ${user.id}');
        debugPrint('💡 [RewardsListPage] Possible reasons:');
        debugPrint('   1. Document không tồn tại trong Firebase với ID: ${user.id}');
        debugPrint('   2. Dữ liệu chưa được upload lên Firebase');
        debugPrint('   3. Firebase rules chặn quyền đọc');
      } else {
        debugPrint('✅ [RewardsListPage] Reward loaded successfully!');
        debugPrint('   - Points: ${reward.points}');
        debugPrint('   - Tier: ${reward.tier}');
        debugPrint('   - UserId: ${reward.userId}');
        debugPrint('   - Vouchers: ${reward.redeemableVouchers.length}');
      }
      
      setState(() {
        _reward = reward;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ [RewardsListPage] Error loading reward: $e');
      debugPrint('📍 [RewardsListPage] Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu phần thưởng: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Phần thưởng',
          style: TextStyle(
            fontSize: screen.ScreenService.largeText,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : _buildRewardsList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
              _errorMessage,
              style: TextStyle(
                fontSize: screen.ScreenService.mediumText,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screen.ScreenService.largeSpacing),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                _loadReward();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsList() {
    if (_reward == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 64,
              color: AppColors.textLight,
            ),
            SizedBox(height: screen.ScreenService.mediumSpacing),
            Text(
              'Chưa có phần thưởng',
              style: TextStyle(
                fontSize: screen.ScreenService.mediumText,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: screen.ScreenService.smallSpacing),
            Text(
              'Hãy đặt hàng để tích điểm nhé!',
              style: TextStyle(
                fontSize: screen.ScreenService.smallText,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });
        await _loadReward();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
        child: _buildRewardCard(_reward!),
      ),
    );
  }

  Widget _buildRewardCard(RewardModel reward) {
    final tierInfo = _getTierInfo(reward.tier);
    final nextTierInfo = reward.nextTier != null ? _getTierInfo(reward.nextTier!) : null;
    final pointsNeeded = nextTierInfo != null ? (nextTierInfo['minPoints'] as int) - reward.points : 0;
    
    return Container(
      margin: EdgeInsets.only(bottom: screen.ScreenService.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with tier and points
          Container(
            padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
            decoration: BoxDecoration(
              gradient: _getTierGradient(reward.tier),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Tier badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTierIcon(reward.tier),
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Hạng ${reward.tier}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Points
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${reward.points}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'điểm hiện tại',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Points needed for next tier
                if (reward.nextTier != null && pointsNeeded > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cần thêm $pointsNeeded điểm để lên hạng ${reward.nextTier}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Tổng tích lũy',
                        '${reward.totalEarned}',
                        Icons.trending_up,
                        AppColors.success,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Đã đổi',
                        '${reward.totalRedeemed}',
                        Icons.redeem,
                        AppColors.warning,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: screen.ScreenService.mediumSpacing),
                
                // Progress to next tier
                if (reward.nextTier != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiến độ đến ${reward.nextTier}',
                        style: TextStyle(
                          fontSize: screen.ScreenService.smallText,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(reward.progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: screen.ScreenService.smallText,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: reward.progress,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getTierColor(reward.nextTier!),
                      ),
                      minHeight: 8,
                    ),
                  ),
                  SizedBox(height: screen.ScreenService.mediumSpacing),
                ],
                
                // Current tier benefits
                const Divider(),
                SizedBox(height: screen.ScreenService.smallSpacing),
                Row(
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Quyền lợi hạng ${reward.tier}',
                      style: TextStyle(
                        fontSize: screen.ScreenService.smallText,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screen.ScreenService.smallSpacing),
                ..._buildTierBenefits(tierInfo['benefits'] as List<String>),
                SizedBox(height: screen.ScreenService.mediumSpacing),
                
                // Redeemable vouchers
                if (reward.redeemableVouchers.isNotEmpty) ...[
                  const Divider(),
                  SizedBox(height: screen.ScreenService.smallSpacing),
                  Row(
                    children: [
                      Icon(
                        Icons.local_offer,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Voucher có thể đổi',
                        style: TextStyle(
                          fontSize: screen.ScreenService.smallText,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screen.ScreenService.smallSpacing),
                  ...reward.redeemableVouchers.map((voucher) => _buildVoucherItem(voucher)),
                ],
                
                // Last updated
                SizedBox(height: screen.ScreenService.smallSpacing),
                Text(
                  'Cập nhật: ${_formatDate(reward.updatedAt)}',
                  style: TextStyle(
                    fontSize: screen.ScreenService.smallText - 2,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: screen.ScreenService.mediumText,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: screen.ScreenService.smallText - 2,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherItem(voucher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              voucher.freeShip ? Icons.local_shipping : Icons.discount,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.title,
                  style: TextStyle(
                    fontSize: screen.ScreenService.smallText,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  voucher.description,
                  style: TextStyle(
                    fontSize: screen.ScreenService.smallText - 2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textLight,
            size: 20,
          ),
        ],
      ),
    );
  }

  LinearGradient _getTierGradient(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'gold':
        return const LinearGradient(
          colors: [Color(0xFFf7971e), Color(0xFFffd200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'silver':
        return const LinearGradient(
          colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'bronze':
        return const LinearGradient(
          colors: [Color(0xFFCD7F32), Color(0xFFE8B88A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [AppColors.textLight, AppColors.border],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return const Color(0xFF667eea);
      case 'gold':
        return const Color(0xFFf7971e);
      case 'silver':
        return const Color(0xFF757F9A);
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return AppColors.textLight;
    }
  }

  IconData _getTierIcon(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return Icons.workspace_premium;
      case 'gold':
        return Icons.stars;
      case 'silver':
        return Icons.star;
      case 'bronze':
        return Icons.star_half;
      default:
        return Icons.star_outline;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
  
  Map<String, dynamic> _getTierInfo(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return {
          'minPoints': 1000,
          'benefits': [
            'Giảm giá 20% cho tất cả đơn hàng',
            'Miễn phí giao hàng không giới hạn',
            'Ưu tiên hỗ trợ khách hàng VIP',
            'Voucher giảm giá đặc biệt hàng tháng',
            'Tích điểm gấp đôi cho mọi đơn hàng',
          ],
        };
      case 'gold':
        return {
          'minPoints': 500,
          'benefits': [
            'Giảm giá 15% cho tất cả đơn hàng',
            'Miễn phí giao hàng cho đơn từ 200K',
            'Voucher giảm giá đặc biệt',
            'Tích điểm x1.5 cho mọi đơn hàng',
          ],
        };
      case 'silver':
        return {
          'minPoints': 200,
          'benefits': [
            'Giảm giá 10% cho đơn hàng đầu tiên mỗi tháng',
            'Miễn phí giao hàng cho đơn từ 300K',
            'Voucher giảm giá theo mùa',
            'Tích điểm x1.2 cho mọi đơn hàng',
          ],
        };
      case 'bronze':
        return {
          'minPoints': 50,
          'benefits': [
            'Giảm giá 5% cho đơn hàng đầu tiên',
            'Tích điểm cho mọi đơn hàng',
            'Nhận thông báo về khuyến mãi',
          ],
        };
      default: // New
        return {
          'minPoints': 0,
          'benefits': [
            'Tích điểm cho mọi đơn hàng',
            'Nhận thông báo về khuyến mãi',
          ],
        };
    }
  }
  
  List<Widget> _buildTierBenefits(List<String> benefits) {
    return benefits.map((benefit) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                benefit,
                style: TextStyle(
                  fontSize: screen.ScreenService.smallText - 1,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}



