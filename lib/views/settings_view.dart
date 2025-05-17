import 'package:flutter/material.dart';
import 'package:yomuyomu/config/global_settings.dart';
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

  @override
  void initState() {
    super.initState();
    _presenter = SettingsPresenter(this);
    _selectedTheme = appThemeMode.value;
    _readerOrientation = userDirectionPreference.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            _buildThemeButton(ThemeMode.system, 'System'),
            _buildThemeButton(ThemeMode.light, 'Light'),
            _buildThemeButton(ThemeMode.dark, 'Dark'),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: _selectedLanguage,
          onChanged: (value) {
            if (value != null) _presenter.onLanguageChanged(value);
          },
          items: ['English', 'Spanish', 'French']
              .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildOrientationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reader Orientation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOrientationButton(Axis.vertical, Icons.vertical_align_center, 'Vertical'),
            _buildOrientationButton(Axis.horizontal, Icons.horizontal_rule, 'Horizontal'),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeButton(ThemeMode mode, String label) {
    final isSelected = _selectedTheme == mode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () => _presenter.onThemeChanged(mode),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
        ),
        child: Text(label),
      ),
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

  // View updates from Presenter
  @override
  void updateTheme(ThemeMode mode) {
    setState(() {
      _selectedTheme = mode;
      appThemeMode.value = mode;
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
      userDirectionPreference.value = orientation;
    });
  }
  
  @override
  void hideLoading() {
  }
  
  @override
  void showError(String message) {
  }
  
  @override
  void showLoading() {
  }
}
