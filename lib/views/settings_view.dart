import 'package:flutter/material.dart';
import 'package:yomuyomu/contracts/settings_contract.dart';
import 'package:yomuyomu/presenters/settings_presenter.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> implements SettingsViewContract {
  late SettingsPresenter _presenter;

  ThemeMode _selectedTheme = ThemeMode.system;
  String _selectedLanguage = 'English';
  Axis _readerOrientation = Axis.vertical;

  bool _loading = true;

  late List<String> _availableLanguages;

  @override
  void initState() {
    super.initState();
    _presenter = SettingsPresenter(this);
    _availableLanguages = _presenter.getAvailableLanguages();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
  setState(() {
    _loading = true;
  });

  try {
    final settings = await _presenter.loadUserSettings();

    setState(() {
      _selectedTheme = _mapThemeFromInt(settings.theme);
      _selectedLanguage = _mapLanguageFromInt(settings.language);
      _readerOrientation = _mapOrientationFromInt(settings.orientation);
      _loading = false;
    });
  } catch (e) {
    setState(() {
      _loading = false;
    });
    showError('Error loading settings: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _buildThemeSection(),
                  const SizedBox(height: 20),
                  _buildLanguageSection(),
                  const SizedBox(height: 20),
                  _buildOrientationSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildThemeSection() {
    return _buildSection(
      title: 'Theme',
      child: Wrap(
        spacing: 8,
        children: [
          _buildThemeButton(ThemeMode.system, 'System'),
          _buildThemeButton(ThemeMode.light, 'Light'),
          _buildThemeButton(ThemeMode.dark, 'Dark'),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return _buildSection(
      title: 'Language',
      child: DropdownButton<String>(
        value: _selectedLanguage,
        onChanged: (value) {
          if (value != null) _presenter.onLanguageChanged(value);
        },
        items: _availableLanguages
            .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
            .toList(),
      ),
    );
  }

  Widget _buildOrientationSection() {
    return _buildSection(
      title: 'Reader Orientation',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOrientationButton(Axis.vertical, Icons.swap_vert, 'Vertical'),
          _buildOrientationButton(Axis.horizontal, Icons.swap_horiz, 'Horizontal'),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildThemeButton(ThemeMode mode, String label) {
    final isSelected = _selectedTheme == mode;
    return ElevatedButton(
      onPressed: () => _presenter.onThemeChanged(mode),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(label),
    );
  }

  Widget _buildOrientationButton(Axis orientation, IconData icon, String label) {
    final isSelected = _readerOrientation == orientation;
    return GestureDetector(
      onTap: () => _presenter.onReaderOrientationChanged(orientation),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            width: 80,
            height: 120,
            child: Icon(icon, size: 50),
          ),
          Text(label),
        ],
      ),
    );
  }

  // View contract updates
  @override
  void updateTheme(ThemeMode mode) {
    setState(() {
      _selectedTheme = mode;
    });
  }

  @override
  void updateLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
  }

  @override
  void updateReaderOrientation(Axis orientation) {
    setState(() {
      _readerOrientation = orientation;
    });
  }

  @override
  void showLoading() {
    setState(() {
      _loading = true;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _loading = false;
    });
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    print(message);
  }

  // Helpers to map DB values to enum/display
  ThemeMode _mapThemeFromInt(int value) {
    switch (value) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Axis _mapOrientationFromInt(int value) {
    return value == 1 ? Axis.horizontal : Axis.vertical;
  }

  String _mapLanguageFromInt(int value) {
    return _availableLanguages.elementAt(value.clamp(0, _availableLanguages.length - 1));
  }
}
