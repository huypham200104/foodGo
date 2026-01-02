import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/screen_service.dart';

class QRService {
  static const String defaultBankCode = "Momo"; // Momo code
  static const String defaultAccountNumber = "0328559320";
  static const String defaultAccountName = "PHAM NGOC HUY";

  // Helper to format currency
  static String _formatAmount(double amount) {
    String amountStr = amount.toStringAsFixed(0);
    String result = '';
    int count = 0;
    for (int i = amountStr.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result';
        count = 0;
      }
      result = '${amountStr[i]}$result';
      count++;
    }
    return result;
  }

  // ============================================================
  // DISPLAY QR CODES (Using MoMo Image)
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
    ScreenService.init(context);
    final imageSize = ScreenService.isSmallScreen ? 200.0 : 250.0;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(ScreenService.mediumSpacing),
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
                                fontSize: ScreenService.largeText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (subtitle != null) ...[
                              SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: ScreenService.smallText,
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
                  
                  SizedBox(height: ScreenService.mediumSpacing),
                  
                  // MoMo QR Image
                  Container(
                    padding: EdgeInsets.all(ScreenService.smallSpacing),
                    decoration: BoxDecoration(
                      color: backgroundColor ?? Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/other/momo.jpg',
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: ScreenService.smallSpacing),
                  
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
                            fontSize: ScreenService.smallText,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'STK: ${defaultAccountNumber}',
                          style: TextStyle(fontSize: ScreenService.smallText, color: Colors.grey[600]),
                        ),
                        Text(
                          'Ngân hàng: Momo',
                          style: TextStyle(fontSize: ScreenService.smallText, color: Colors.grey[600]),
                        ),
                        Text(
                          'Chủ TK: ${defaultAccountName}',
                          style: TextStyle(fontSize: ScreenService.smallText, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: ScreenService.smallSpacing),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _copyBankInfo();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã sao chép thông tin chuyển khoản'),
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
    ScreenService.init(context);
    final imageSize = ScreenService.isSmallScreen ? 180.0 : 220.0;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(ScreenService.mediumSpacing),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: ScreenService.smallSpacing),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ScreenService.largeText,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                if (subtitle != null) ...[
                  SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ScreenService.smallText,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                SizedBox(height: ScreenService.mediumSpacing),
                
                // MoMo QR Image
                Container(
                  padding: EdgeInsets.all(ScreenService.smallSpacing),
                  decoration: BoxDecoration(
                    color: backgroundColor ?? Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/other/momo.jpg',
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                SizedBox(height: ScreenService.mediumSpacing),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _copyBankInfo();
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
          ),
        );
      },
    );
  }

  // ============================================================
  // QR CODE WIDGETS
  // ============================================================

  /// Widget QR Code có thể tái sử dụng (Using MoMo Image)
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/other/momo.jpg',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Copy bank information to clipboard
  static Future<void> _copyBankInfo() async {
    final bankInfo = '''
STK: $defaultAccountNumber
Ngân hàng: Momo
Chủ TK: $defaultAccountName
''';
    await Clipboard.setData(ClipboardData(text: bankInfo));
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
    await showQRDialog(
      context,
      qrData: 'FOODGO $orderId - ${_formatAmount(amount)}đ',
      title: 'Thanh toán đơn hàng',
      subtitle: 'Mã: $orderId - Số tiền: ${_formatAmount(amount)}đ',
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
    );
  }
}
