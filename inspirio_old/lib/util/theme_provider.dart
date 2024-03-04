import 'package:flutter/material.dart';
import 'package:inspirio/themes/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  late ThemeData _themeData;

  ThemeProvider() {
    _themeData = kLightTheme;
    _loadTheme();
  }

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('theme');

    if (themeName != null) {
      if (themeName == 'light') {
        _themeData = kLightTheme;
      } else if (themeName == 'amoled') {
        _themeData = kAmoledTheme;
      } else if (themeName == 'coloured') {
        _themeData = kColouredTheme;
      }
    } else {
      _themeData = kLightTheme;
    }
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (_themeData == kLightTheme) {
      prefs.setString('theme', 'light');
    } else if (_themeData == kAmoledTheme) {
      prefs.setString('theme', 'amoled');
    } else if (_themeData == kColouredTheme) {
      prefs.setString('theme', 'coloured');
    }
  }

  void toggleTheme() {
    if (_themeData == kLightTheme) {
      _themeData = kLightTheme;
    } else if (_themeData == kAmoledTheme) {
      _themeData = kAmoledTheme;
    } else if (_themeData == kColouredTheme) {
      _themeData = kColouredTheme;
    }
    _saveTheme();
    notifyListeners();
  }
}
