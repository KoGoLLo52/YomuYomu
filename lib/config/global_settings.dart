// global_settings.dart
import 'package:flutter/material.dart';

final ValueNotifier<Axis> userDirectionPreference = ValueNotifier(Axis.vertical);
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.system);