import 'package:foodgo/services/screen_service.dart';

class Dimensions {
  // Form dimensions
  static double get tabBarHeight => ScreenService.isSmallScreen ? 45 : 50;
  static double get inputFieldHeight => ScreenService.buttonHeight;
  static double get loginButtonHeight => ScreenService.buttonHeight;
  
  // Login page specific
  static double get logoSize => ScreenService.isSmallScreen ? 50 : 60;
  static double get logoContainerPadding => ScreenService.isSmallScreen ? 16 : 20;
  
  // TabBar content height - GIẢI QUYẾT VẤN ĐỀ OVERFLOW
  static double get tabContentMinHeight {
    // Tính toán dựa trên nội dung thực tế
    double emailFormHeight = inputFieldHeight * 2 + // 2 input fields
                           ScreenService.formSpacing * 2 + // spacing between inputs
                           ScreenService.sectionSpacing + // spacing before button
                           loginButtonHeight; // button height
    
    double phoneFormHeight = inputFieldHeight + // 1 input field
                           ScreenService.formSpacing + // spacing after input
                           40 + // text message height
                           ScreenService.sectionSpacing + // spacing before button
                           loginButtonHeight; // button height
    
    // Lấy giá trị lớn hơn và thêm buffer
    return (emailFormHeight > phoneFormHeight ? emailFormHeight : phoneFormHeight) + 20;
  }
  
  // Spacing
  static double get headerSpacing => ScreenService.isSmallScreen ? 32 : 40;
  static double get sectionSpacing => ScreenService.sectionSpacing;
  static double get formSpacing => ScreenService.formSpacing;
}