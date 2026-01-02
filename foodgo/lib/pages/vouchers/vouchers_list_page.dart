import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../services/screen_service.dart' as screen;
import '../../services/voucher_service.dart';
import '../../models/voucher_model.dart';

class VouchersListPage extends StatefulWidget {
  const VouchersListPage({super.key});

  @override
  State<VouchersListPage> createState() => _VouchersListPageState();
}

class _VouchersListPageState extends State<VouchersListPage> {
  List<VoucherModel> _vouchers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isScreenServiceInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isScreenServiceInitialized) {
      screen.ScreenService.init(context);
      _isScreenServiceInitialized = true;
      _loadVouchers();
    }
  }

  Future<void> _loadVouchers() async {
    try {
      final vouchers = await VoucherService.getAllVouchers();
      
      // Filter only active vouchers (not expired)
      final now = DateTime.now();
      final activeVouchers = vouchers.where((v) => v.expiryDate.isAfter(now)).toList();
      
      setState(() {
        _vouchers = activeVouchers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách voucher: $e';
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
          'Voucher Khả Dụng',
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
              : _buildVouchersList(),
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
                _loadVouchers();
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

  Widget _buildVouchersList() {
    if (_vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 64,
              color: AppColors.textLight,
            ),
            SizedBox(height: screen.ScreenService.mediumSpacing),
            Text(
              'Chưa có voucher khả dụng',
              style: TextStyle(
                fontSize: screen.ScreenService.mediumText,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: screen.ScreenService.smallSpacing),
            Text(
              'Hãy quay lại sau nhé!',
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
        await _loadVouchers();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
        itemCount: _vouchers.length,
        itemBuilder: (context, index) {
          return _buildVoucherCard(_vouchers[index]);
        },
      ),
    );
  }

  Widget _buildVoucherCard(VoucherModel voucher) {
    final daysLeft = voucher.expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysLeft <= 7;

    return Container(
      margin: EdgeInsets.only(bottom: screen.ScreenService.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpiringSoon ? AppColors.warning.withValues(alpha: 0.3) : AppColors.border,
          width: 1,
        ),
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
          // Header with discount value
          Container(
            padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  voucher.freeShip ? Icons.local_shipping : Icons.discount,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (voucher.discountValue > 0)
                        Text(
                          'Giảm ${NumberFormat.currency(locale: 'vi', symbol: 'đ').format(voucher.discountValue)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(screen.ScreenService.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Voucher code
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.confirmation_number,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        voucher.code,
                        style: TextStyle(
                          fontSize: screen.ScreenService.mediumText,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screen.ScreenService.smallSpacing),

                // Description
                Text(
                  voucher.description,
                  style: TextStyle(
                    fontSize: screen.ScreenService.smallText,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: screen.ScreenService.smallSpacing),

                // Min order value
                if (voucher.minOrderValue > 0)
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Đơn tối thiểu: ${NumberFormat.currency(locale: 'vi', symbol: 'đ').format(voucher.minOrderValue)}',
                        style: TextStyle(
                          fontSize: screen.ScreenService.smallText - 1,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),

                SizedBox(height: screen.ScreenService.smallSpacing),

                // Expiry date
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isExpiringSoon ? AppColors.warning : AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'HSD: ${DateFormat('dd/MM/yyyy').format(voucher.expiryDate)}',
                      style: TextStyle(
                        fontSize: screen.ScreenService.smallText - 1,
                        color: isExpiringSoon ? AppColors.warning : AppColors.textLight,
                        fontWeight: isExpiringSoon ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (isExpiringSoon) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Sắp hết hạn',
                          style: TextStyle(
                            fontSize: screen.ScreenService.smallText - 2,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Usage limit
                if (voucher.usageLimit > 0) ...[
                  SizedBox(height: screen.ScreenService.smallSpacing),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Còn ${voucher.usageLimit - voucher.usedCount}/${voucher.usageLimit} lượt',
                        style: TextStyle(
                          fontSize: screen.ScreenService.smallText - 1,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


