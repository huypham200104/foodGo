import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US'); // Default locale

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void setVietnamese() {
    setLocale(const Locale('vi', 'VN'));
  }

  void setEnglish() {
    setLocale(const Locale('en', 'US'));
  }
}
