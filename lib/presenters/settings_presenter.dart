import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yomuyomu/config/global_settigns.dart';
import 'package:yomuyomu/contracts/settings_contract.dart';

class SettingsPresenter {
  final SettingsViewContract _view;

  SettingsPresenter(this._view);

  void onThemeChanged(ThemeMode mode) async {
    appThemeMode.value = mode; // Actualiza en tiempo real

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme_mode', _themeModeToString(mode));

    _view.updateTheme(mode);
  }

  void onLanguageChanged(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    _view.updateLanguage(language);
  }

  void onReaderOrientationChanged(Axis orientation) async {
    userDirectionPreference.value = orientation;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reader_orientation', orientation == Axis.horizontal ? 'horizontal' : 'vertical');
    _view.updateReaderOrientation(orientation);
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}
