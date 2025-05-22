import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yomuyomu/config/global_settings.dart';
import 'package:yomuyomu/contracts/settings_contract.dart';
import 'package:yomuyomu/helpers/database_helper.dart';
import 'package:yomuyomu/models/settings_model.dart';

class SettingsPresenter {
  final SettingsViewContract _view;
  String userID = FirebaseAuth.instance.currentUser?.uid ?? "local";

  SettingsPresenter(this._view);

  void onThemeChanged(ThemeMode mode) async {
    appThemeMode.value = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _themeModeToString(mode));
    _view.updateTheme(mode);

    final int themeValue = _themeModeToInt(mode);
    await _updateSettingInDatabase(theme: themeValue);
  }

  void onLanguageChanged(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    _view.updateLanguage(languageCode);

    final int languageValue = _languageCodeToInt(languageCode);
    await _updateSettingInDatabase(language: languageValue);
  }

  void onReaderOrientationChanged(Axis orientation) async {
    userDirectionPreference.value = orientation;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'reader_orientation',
      orientation == Axis.horizontal ? 'horizontal' : 'vertical',
    );
    _view.updateReaderOrientation(orientation);

    final int orientationValue = orientation == Axis.horizontal ? 1 : 0;
    await _updateSettingInDatabase(orientation: orientationValue);
  }

  Future<SettingsModel> loadUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final map = await DatabaseHelper.instance.getUserSettingsById(userID);

    if (map == null) {
      final defaultSettings = SettingsModel(
        userID: userID,
        language: 0,
        theme: 0,
        orientation: 0,
        syncStatus: 0,
      );
      await DatabaseHelper.instance.insertUserSettings(defaultSettings.toMap());

      // Guardar también en preferencias
      await prefs.setString(
        'language',
        _mapLanguageFromInt(defaultSettings.language),
      );
      await prefs.setString(
        'theme_mode',
        _themeModeToString(_mapIntToThemeMode(defaultSettings.theme)),
      );
      await prefs.setString(
        'reader_orientation',
        defaultSettings.orientation == 1 ? 'horizontal' : 'vertical',
      );

      return defaultSettings;
    }

    final settings = SettingsModel.fromMap(map);

    appThemeMode.value = _mapIntToThemeMode(settings.theme);
    userDirectionPreference.value = _mapIntToOrientation(settings.orientation);

    await prefs.setString('theme_mode', _themeModeToString(appThemeMode.value));
    await prefs.setString('language', _mapLanguageFromInt(settings.language));
    await prefs.setString(
      'reader_orientation',
      settings.orientation == 1 ? 'horizontal' : 'vertical',
    );

    return settings;
  }

  Future<void> _updateSettingInDatabase({
    int? theme,
    int? language,
    int? orientation,
  }) async {
    final existingMap = await DatabaseHelper.instance.getUserSettingsById(
      userID,
    );
    if (existingMap == null) {
      final newSettings = SettingsModel(
        userID: userID,
        language: language ?? 0,
        theme: theme ?? 0,
        orientation: orientation ?? 0,
        syncStatus: 0,
      );
      await DatabaseHelper.instance.insertUserSettings(newSettings.toMap());
    } else {
      final existing = SettingsModel.fromMap(existingMap);
      final updatedModel = SettingsModel(
        userID: userID,
        language: language ?? existing.language,
        theme: theme ?? existing.theme,
        orientation: orientation ?? existing.orientation,
        syncStatus: 0,
      );
      await DatabaseHelper.instance.updateUserSettings(
        updatedModel.toMap(),
        userID,
      );
    }
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

  int _themeModeToInt(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      default:
        return 0;
    }
  }

  final List<String> languageCodes = ['English', 'Español', 'Français'];

  int _languageCodeToInt(String languageCode) {
    return languageCodes
        .indexOf(languageCode)
        .clamp(0, languageCodes.length - 1);
  }

  String _mapLanguageFromInt(int value) {
    return languageCodes[value.clamp(0, languageCodes.length - 1)];
  }

  List<String> getAvailableLanguages() => languageCodes;

  ThemeMode _mapIntToThemeMode(int value) {
    switch (value) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Axis _mapIntToOrientation(int value) {
    return value == 1 ? Axis.horizontal : Axis.vertical;
  }
}
