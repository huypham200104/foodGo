import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/voucher_model.dart';
import '../../../../services/screen_service.dart';
import '../../../../utils/format_helper.dart';

class RedeemableVouchersWidget extends StatelessWidget {
  final List<VoucherModel> vouchers;
  final VoucherModel? selectedVoucher;
  final Function(VoucherModel) onSelect;

  const RedeemableVouchersWidget({
    super.key,
    required this.vouchers,
    this.selectedVoucher,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (vouchers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ưu đãi của bạn',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: ScreenService.smallSpacing),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vouchers.length,
          separatorBuilder: (context, index) => SizedBox(height: ScreenService.smallSpacing),
          itemBuilder: (context, index) {
            final voucher = vouchers[index];
            final isSelected = selectedVoucher?.id == voucher.id;

            return GestureDetector(
              onTap: () => onSelect(voucher),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon or Image
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_offer,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voucher.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            voucher.description,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          if (voucher.minOrderValue > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Đơn tối thiểu: ${FormatHelper.formatCurrency(voucher.minOrderValue)}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Checkbox
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}


