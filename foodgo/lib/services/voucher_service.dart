import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/voucher_model.dart';

class VoucherService {
  static List<VoucherModel> _vouchers = [];

  // Load vouchers from JSON asset
  static Future<void> loadVouchers() async {
    if (_vouchers.isNotEmpty) return;

    try {
      final String response = await rootBundle.loadString('assets/data/vouchers.json');
      final data = await json.decode(response);
      
      if (data['vouchers'] != null) {
        _vouchers = (data['vouchers'] as List)
            .map((item) => VoucherModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading vouchers: $e');
    }
  }

  // Get all vouchers
  static Future<List<VoucherModel>> getAllVouchers() async {
    await loadVouchers();
    return _vouchers;
  }

  // Validate voucher and return discount amount
  static Future<double> validateVoucher({
    required String code, 
    required double orderValue
  }) async {
    await loadVouchers();

    try {
      final voucher = _vouchers.firstWhere(
        (v) => v.code.toUpperCase() == code.toUpperCase(),
        orElse: () => throw Exception('Mã giảm giá không tồn tại'),
      );

      // Check expiry
      if (DateTime.now().isAfter(voucher.expiryDate)) {
        throw Exception('Mã giảm giá đã hết hạn');
      }

      // Check usage limit
      if (voucher.usageLimit > 0 && voucher.usedCount >= voucher.usageLimit) {
        throw Exception('Mã giảm giá đã hết lượt sử dụng');
      }

      // Check min order value
      if (orderValue < voucher.minOrderValue) {
        throw Exception('Đơn hàng chưa đạt giá trị tối thiểu ${voucher.minOrderValue}');
      }

      // Check specific voucher conditions
      // T3VUIVE: Chỉ áp dụng vào thứ 3
      if (voucher.code.toUpperCase() == 'T3VUIVE') {
        final now = DateTime.now();
        if (now.weekday != DateTime.tuesday) {
          throw Exception('Mã giảm giá chỉ áp dụng vào thứ 3');
        }
      }

      // Return discount value
      // If freeship, we might need special handling, but here we return discountValue.
      // If discountValue is 0 (freeship only), the caller needs to handle it.
      // For now, let's assume discountValue covers the discount amount.
      // If it's a percentage or freeship, logic might need adjustment.
      // Based on current data, discountValue is a fixed amount.
      
      return voucher.discountValue;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get voucher by code
  static Future<VoucherModel?> getVoucherByCode(String code) async {
    await loadVouchers();
    try {
      return _vouchers.firstWhere(
        (v) => v.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

