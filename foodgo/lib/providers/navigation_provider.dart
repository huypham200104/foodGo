import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  String _currentRoute = '/home';

  int get currentIndex => _currentIndex;
  String get currentRoute => _currentRoute;

  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void setCurrentRoute(String route) {
    if (_currentRoute != route) {
      _currentRoute = route;
      
      // Map routes to bottom nav indices
      switch (route) {
        case '/home':
          _currentIndex = 0;
          break;
        case '/notification':
          _currentIndex = 1;
          break;
        case '/cart':
          _currentIndex = 2;
          break;
        case '/profile':
          _currentIndex = 3;
          break;
        default:
          // Don't change index for other routes
          break;
      }
      
      notifyListeners();
    }
  }

  void resetToHome() {
    _currentIndex = 0;
    _currentRoute = '/home';
    notifyListeners();
  }
}