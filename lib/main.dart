import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:yomuyomu/config/global_settings.dart';
import 'package:yomuyomu/firebase_options.dart';
import 'package:yomuyomu/helpers/database_helper.dart';
import 'package:yomuyomu/insert_mock_data.dart';
import 'package:yomuyomu/views/account_view.dart';
import 'package:yomuyomu/views/history_view.dart';
import 'package:yomuyomu/views/library_view.dart';
import 'package:yomuyomu/views/settings_view.dart';

import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Inicializando SharedPreferences');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final preferences = await SharedPreferences.getInstance();
  final themePreference = preferences.getString('theme_mode') ?? 'system';
  final languagePreference = preferences.getString('language') ?? 'en';
  final readerOrientation =
      preferences.getString('reader_orientation') ?? 'vertical';

  userDirectionPreference.value =
      readerOrientation == 'horizontal' ? Axis.horizontal : Axis.vertical;

  print('Idioma preferido: $languagePreference');

  appThemeMode.value = _getThemeFromPreference(themePreference);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    print('Inicializando sqflite_common_ffi para escritorio');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else {
    print('No se usa sqflite_common_ffi en esta plataforma');
  }

  try {
    // print('Borrando base de datos (si existe)');
    // await DatabaseHelper.instance.deleteDatabaseFile();
    // print('Base de datos borrada');

    // print('Insertando datos de muestra');
    // await insertSampleData();
    // print('Datos de muestra insertados');

    print('Abriendo base de datos');
    await DatabaseHelper.instance.database;
    print('Base de datos abierta');
  } catch (e, st) {
    print('Error durante inicialización de base de datos: $e');
    print(st);
  }

  print('Ejecutando la app');
  runApp(const AppRoot());
}

ThemeMode _getThemeFromPreference(String preference) {
  switch (preference) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

Future<void> updateThemePreference(ThemeMode mode) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString('theme_mode', _getThemePreferenceString(mode));
  appThemeMode.value = mode;
}

String _getThemePreferenceString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    default:
      return 'system';
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Manga Reader',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final List<Widget> screenViews = const [
    LibraryView(),
    HistoryView(),
    AccountView(),
    SettingsView(),
  ];

  final List<String> screenTitles = const [
    "Library",
    "History",
    "Account",
    "Settings",
  ];

  void onNavItemSelected(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Widget _buildNavigationDrawer(BuildContext context, bool isWideScreen) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onNavItemSelected,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.library_books),
          label: Text('Library'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.history),
          label: Text('History'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.account_circle),
          label: Text('Account'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(
            title: Text(screenTitles[currentIndex]),
            leading:
                isWideScreen
                    ? null
                    : Builder(
                      builder:
                          (context) => IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                    ),
          ),
          drawer:
              isWideScreen
                  ? null
                  : Drawer(
                    child: ListView(
                      children: [
                        for (int i = 0; i < screenTitles.length; i++)
                          ListTile(
                            title: Text(screenTitles[i]),
                            leading: _getIconForScreen(i),
                            selected: currentIndex == i,
                            onTap: () {
                              onNavItemSelected(i);
                              Navigator.pop(context);
                            },
                          ),
                      ],
                    ),
                  ),
          body: Row(
            children: [
              if (isWideScreen) _buildNavigationDrawer(context, true),
              Expanded(
                child: IndexedStack(index: currentIndex, children: screenViews),
              ),
            ],
          ),
        );
      },
    );
  }

  Icon _getIconForScreen(int index) {
    switch (index) {
      case 0:
        return const Icon(Icons.library_books);
      case 1:
        return const Icon(Icons.history);
      case 2:
        return const Icon(Icons.account_circle);
      case 3:
      default:
        return const Icon(Icons.settings);
    }
  }
}
