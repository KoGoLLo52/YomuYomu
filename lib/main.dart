import 'package:flutter/material.dart';
import 'package:yomuyomu/views/browse_view.dart';
import 'views/library_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manga Reader',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainNavigationView(),
    );
  }
}

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _selectedIndex = 0;

  final List<Widget> _views = [
    const LibraryView(),
    const BrowseView(),
    const LibraryView(),
    const LibraryView(),
    const LibraryView(),
    ];

  final List<String> _titles = [
    "Library",
    "Browse",
    "History",
    "Account",
    "Settings",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDrawer(BuildContext context, bool isPermanent) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.library_books),
          label: Text('Library'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.browse_gallery),
          label: Text('Browse'),
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
            title: Text(_titles[_selectedIndex]),
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
                        ListTile(
                          title: const Text("Library"),
                          leading: const Icon(Icons.library_books),
                          selected: _selectedIndex == 0,
                          onTap: () {
                            _onItemTapped(0);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text("Browse"),
                          leading: const Icon(Icons.browse_gallery),
                          selected: _selectedIndex == 1,
                          onTap: () {
                            _onItemTapped(1);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text("History"),
                          leading: const Icon(Icons.history),
                          selected: _selectedIndex == 2,
                          onTap: () {
                            _onItemTapped(2);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text("Account"),
                          leading: const Icon(Icons.account_circle),
                          selected: _selectedIndex == 3,
                          onTap: () {
                            _onItemTapped(3);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text("Settings"),
                          leading: const Icon(Icons.settings),
                          selected: _selectedIndex == 4,
                          onTap: () {
                            _onItemTapped(4);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
          body: Row(
            children: [
              if (isWideScreen) _buildDrawer(context, true),
              Expanded(child: _views[_selectedIndex]),
            ],
          ),
        );
      },
    );
  }
}
