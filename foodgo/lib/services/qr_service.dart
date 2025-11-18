import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vietqr_flutter/vietqr_flutter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class QRService {
  static const String defaultBankCode = "970433"; // Vietcombank code
  static const String defaultAccountNumber = "0328559320";
  static const String defaultAccountName = "PHAM NGOC HUY";

  // ============================================================
  // GENERATE QR CODES
  // ============================================================

  /// Tạo QR Code cho thanh toán VietQR
  static String generateVietQRString({
    required double amount,
    String? orderId,
    String? description,
    String? bankCode,
    String? accountNumber,
    String? accountName,
  }) {
    try {
      // 👈 FIXED: Sử dụng đúng API từ tài liệu
      String qrCode = VietQRGenerator.generate(
        accountNumber: accountNumber ?? defaultAccountNumber,
        bankCode: bankCode ?? defaultBankCode,
      );

      return qrCode;
    } catch (e) {
      return generateSimplePaymentQR(
        amount: amount,
        orderId: orderId ?? '',
        bankCode: bankCode,
        accountNumber: accountNumber,
        accountName: accountName,
      );
    }
  }

  /// Tạo QR Code thông thường
  static String generateCustomQR({
    required String content,
  }) {
    return content;
  }

  // ============================================================
  // DISPLAY QR CODES
  // ============================================================

  /// Hiển thị QR Code trong Dialog
  static Future<void> showQRDialog(
    BuildContext context, {
    required String qrData,
    required String title,
    String? subtitle,
    VoidCallback? onSave,
    VoidCallback? onShare,
    Color? foregroundColor,
    Color? backgroundColor,
    double size = 280.0,
  }) async {
    final GlobalKey qrKey = GlobalKey();

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (subtitle != null) ...[
                            SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // QR Code
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor ?? Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: RepaintBoundary(
                    key: qrKey,
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: size,
                      foregroundColor: foregroundColor ?? Colors.black,
                      backgroundColor: backgroundColor ?? Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Bank Information Display
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin chuyển khoản:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'STK: ${defaultAccountNumber}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        'Ngân hàng: Vietcombank',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        'Chủ TK: ${defaultAccountName}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _copyQRData(qrData);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã sao chép thông tin QR'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          onSave?.call();
                        },
                        icon: Icon(Icons.copy),
                        label: Text('Sao chép'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onShare?.call();
                        },
                        icon: Icon(Icons.close),
                        label: Text('Đóng'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Hiển thị QR Code trong BottomSheet
  static Future<void> showQRBottomSheet(
    BuildContext context, {
    required String qrData,
    required String title,
    String? subtitle,
    Color? foregroundColor,
    Color? backgroundColor,
    double size = 250.0,
    VoidCallback? onSave,
    VoidCallback? onShare,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              if (subtitle != null) ...[
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              SizedBox(height: 24),
              
              // QR Code
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: size,
                  foregroundColor: foregroundColor ?? Colors.black,
                  backgroundColor: backgroundColor ?? Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),
              
              SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await _copyQRData(qrData);
                        onSave?.call();
                      },
                      icon: Icon(Icons.copy),
                      label: Text('Sao chép'),
                    ),
                  ),
                  
                  SizedBox(width: 12),
                  
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onShare?.call();
                      },
                      icon: Icon(Icons.close),
                      label: Text('Đóng'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Safe area bottom
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // QR CODE WIDGETS
  // ============================================================

  /// Widget QR Code có thể tái sử dụng
  static Widget buildQRWidget({
    required String qrData,
    double size = 200.0,
    Color? foregroundColor,
    Color? backgroundColor,
    Widget? embeddedImage,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return Container(
      padding: padding ?? EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border ?? Border.all(color: Colors.grey[300]!),
      ),
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: size,
        foregroundColor: foregroundColor ?? Colors.black,
        backgroundColor: backgroundColor ?? Colors.white,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      ),
    );
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Copy QR data to clipboard
  static Future<void> _copyQRData(String qrData) async {
    await Clipboard.setData(ClipboardData(text: qrData));
  }

  // ============================================================
  // CONVENIENCE METHODS
  // ============================================================

  /// Hiển thị QR thanh toán đơn hàng
  static Future<void> showPaymentQR(
    BuildContext context, {
    required String orderId,
    required double amount,
    String? description,
    String? bankCode,
    String? accountNumber,
    String? accountName,
  }) async {
    final qrData = generateVietQRString(
      amount: amount,
      orderId: orderId,
      description: description ?? 'FOODGO $orderId',
      bankCode: bankCode,
      accountNumber: accountNumber,
      accountName: accountName,
    );

    await showQRDialog(
      context,
      qrData: qrData,
      title: 'Thanh toán đơn hàng',
      subtitle: 'Mã: $orderId - Số tiền: ${amount.toStringAsFixed(0)}đ',
      foregroundColor: Colors.blue[800],
    );
  }

  /// Hiển thị QR custom với content bất kỳ
  static Future<void> showCustomQR(
    BuildContext context, {
    required String content,
    required String title,
    String? subtitle,
    Color? color,
  }) async {
    await showQRDialog(
      context,
      qrData: content,
      title: title,
      subtitle: subtitle,
      foregroundColor: color,
    );
  }

  // ============================================================
  // ALTERNATIVE SIMPLE QR GENERATION (Fallback)
  // ============================================================

  /// Tạo QR đơn giản cho thanh toán (fallback nếu VietQR không hoạt động)
  static String generateSimplePaymentQR({
    required double amount,
    required String orderId,
    String? bankCode,
    String? accountNumber,
    String? accountName,
  }) {
    // Tạo content đơn giản cho QR theo format chuẩn
    final paymentInfo = [
      'STK: ${accountNumber ?? defaultAccountNumber}',
      'Ngan hang: Vietcombank', 
      'Chu TK: ${accountName ?? defaultAccountName}',
      'So tien: ${amount.toStringAsFixed(0)} VND',
      'Noi dung: FOODGO $orderId',
    ].join('\n');
    
    return paymentInfo;
  }

  /// Hiển thị QR thanh toán đơn giản (fallback)
  static Future<void> showSimplePaymentQR(
    BuildContext context, {
    required String orderId,
    required double amount,
    String? bankCode,
    String? accountNumber,
    String? accountName,
  }) async {
    final qrData = generateSimplePaymentQR(
      amount: amount,
      orderId: orderId,
      bankCode: bankCode,
      accountNumber: accountNumber,
      accountName: accountName,
    );

    await showQRDialog(
      context,
      qrData: qrData,
      title: 'Thông tin thanh toán',
      subtitle: 'Mã: $orderId - Số tiền: ${amount.toStringAsFixed(0)}đ',
      foregroundColor: Colors.green[800],
    );
  }

  // ============================================================
  // QR IMAGE GENERATION (Optional Enhancement)
  // ============================================================

  /// Tạo QR với hình ảnh ngân hàng (theo tài liệu)
  static Widget buildQRWithBankImage({
    required String qrData,
    double size = 300.0,
    double sizeEmbeddingImage = 50.0,
  }) {
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      embeddedImage: AssetImage('assets/images/bank.png'), // Bank logo
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: Size(sizeEmbeddingImage, sizeEmbeddingImage),
      ),
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }
}