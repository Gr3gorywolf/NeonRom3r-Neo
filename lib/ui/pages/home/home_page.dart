import 'package:flutter/material.dart';
import 'package:neonrom3r/ui/pages/downloads/downloads_page.dart';
import 'package:neonrom3r/ui/pages/emulators/emulators_page.dart';
import 'package:neonrom3r/ui/pages/roms/roms_page.dart';
import 'package:neonrom3r/ui/pages/settings/settings_page.dart';
import 'package:neonrom3r/utils/assets_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> routes = [
      RomsPage(),
      EmulatorsPage(),
      DownloadsPage(),
      SettingsPage()
    ];
    return Scaffold(
      body: routes[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.games),
              title: Text("Roms"),
              backgroundColor: Colors.green),
          BottomNavigationBarItem(
              icon: AssetsHelper.getIcon("arcade"),
              title: Text("Emulators"),
              backgroundColor: Colors.green),
          BottomNavigationBarItem(
              icon: Icon(Icons.download_sharp),
              title: Text("Downloads"),
              backgroundColor: Colors.green),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text("Settings"),
              backgroundColor: Colors.green)
        ],
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
