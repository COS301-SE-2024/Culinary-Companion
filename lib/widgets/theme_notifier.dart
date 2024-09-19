import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  final SharedPreferences prefs;
  static const String themePrefKey = "isDarkTheme";

  bool _isDarkTheme;

  ThemeNotifier({required this.prefs})
      : _isDarkTheme = prefs.getBool(themePrefKey) ?? false;

  bool get isDarkTheme => _isDarkTheme;

  ThemeMode get currentTheme => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    prefs.setBool(themePrefKey, _isDarkTheme);
    notifyListeners();
  }
}
