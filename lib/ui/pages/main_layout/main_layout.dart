import 'dart:ffi';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:yamata_launcher/app_theme.dart';
import 'package:yamata_launcher/services/native/seven_zip_android_interface.dart';
import 'package:yamata_launcher/services/native/aria2c_android_interface.dart';
import 'package:yamata_launcher/services/files_system_service.dart';
import 'package:yamata_launcher/ui/pages/downloads/downloads_page.dart';
import 'package:yamata_launcher/ui/pages/library/library_page.dart';
import 'package:yamata_launcher/ui/pages/home/home_page.dart';
import 'package:yamata_launcher/ui/pages/settings/settings_page.dart';
import 'package:yamata_launcher/services/assets_service.dart';
import 'package:yamata_launcher/utils/screen_helpers.dart';

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> routes = [
      HomePage(),
      LibraryPage(),
      DownloadsPage(),
      SettingsPage()
    ];
    var isSmallScreen = ScreenHelpers.isSmallScreen(context);
    var isMediumScreen = ScreenHelpers.isMediumScreen(context);
    const navigationItems = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.collections_bookmark, 'label': 'Library'},
      {'icon': Icons.download_sharp, 'label': 'Downloads'},
      {'icon': Icons.settings, 'label': 'Settings'},
    ];

    _getLogo() {
      if (isMediumScreen) {
        return AssetsService.getSvgImage("logo-orig", size: 65);
      } else {
        return Center(child: AssetsService.getSvgImage("logo-orig", size: 100));
      }
    }

    Widget buildDesktopBody() {
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
                padding: const EdgeInsets.only(top: 0), child: _getLogo()),
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
