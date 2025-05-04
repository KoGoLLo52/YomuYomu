import 'package:flutter/material.dart';

abstract class SettingsViewContract {
  void updateTheme(ThemeMode mode);
  void updateLanguage(String language);
  void updateReaderOrientation(Axis orientation);
}

