import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/app_theme.dart';
import 'package:neonrom3r/ui/pages/downloads/downloads_page.dart';
import 'package:neonrom3r/ui/pages/emulators/emulators_page.dart';
import 'package:neonrom3r/ui/pages/home/home_page.dart';
import 'package:neonrom3r/ui/pages/settings/settings_page.dart';
import 'package:neonrom3r/services/assets_service.dart';
import 'package:neonrom3r/utils/screen_helpers.dart';

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> routes = [
      HomePage(),
      EmulatorsPage(),
      DownloadsPage(),
      SettingsPage()
    ];
    var isSmallScreen = ScreenHelpers.isSmallScreen(context);
    const navigationItems = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.apps, 'label': 'Library'},
      {'icon': Icons.download_sharp, 'label': 'Downloads'},
      {'icon': Icons.settings, 'label': 'Settings'},
    ];

    Widget buildDesktopBody() {
      var isMediumScreen = ScreenHelpers.isMediumScreen(context);
      return Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            indicatorColor: Colors.transparent,
            selectedLabelTextStyle: TextStyle(color: primaryGreen),
            selectedIconTheme: IconThemeData(color: primaryGreen),
            extended: !isMediumScreen,
            onDestinationSelected: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            minExtendedWidth: 190,
            minWidth: 60,
            useIndicator: true,
            leading: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: AssetsService.getImage(
                    isMediumScreen ? "logo" : "logolarge",
                    size: 50,
                    width: isMediumScreen ? 50 : 180)),
            destinations: navigationItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item['icon'] as IconData),
                label: Text(item['label'] as String),
              );
            }).toList(),
          ),
          VerticalDivider(thickness: 1, width: 1, color: grayBorderColor),
          Expanded(
            child: routes[_currentIndex],
          )
        ],
      );
    }

    return Scaffold(
      body: routes[_currentIndex],
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: grayBorderColor,
              width: 0.5,
            ),
          ),
        ),
        child: isSmallScreen
            ? BottomNavigationBar(
                currentIndex: _currentIndex,
                showUnselectedLabels: true,
                items: navigationItems.map((item) {
                  return BottomNavigationBarItem(
                      icon: Icon(item['icon'] as IconData),
                      label: item['label'] as String);
                }).toList(),
                onTap: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              )
            : buildDesktopBody(),
      ),
    );
  }
}
