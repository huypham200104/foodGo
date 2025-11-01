import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get theme => _isDarkMode ? _darkTheme : _lightTheme;
  ThemeData get currentTheme => theme; // Alias cho theme

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    // Thêm các thuộc tính theme khác
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    // Thêm các thuộc tính theme khác
  );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLightTheme() {
    _isDarkMode = false;
    notifyListeners();
  }

  void setDarkTheme() {
    _isDarkMode = true;
    notifyListeners();
  }
}