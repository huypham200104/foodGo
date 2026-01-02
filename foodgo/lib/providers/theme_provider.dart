import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart'; // Import AppTheme

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  // Sửa getter name
  ThemeData get themeData => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  get theme => null;
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  
  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
  
  void setLightMode() {
    _isDarkMode = false;
    notifyListeners();
  }
}
