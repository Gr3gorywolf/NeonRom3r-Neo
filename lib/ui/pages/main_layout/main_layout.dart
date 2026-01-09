import 'package:flutter/material.dart';
import 'package:yamata_launcher/app_theme.dart';
import 'package:yamata_launcher/ui/pages/downloads/downloads_page.dart';
import 'package:yamata_launcher/ui/pages/library/library_page.dart';
import 'package:yamata_launcher/ui/pages/home/home_page.dart';
import 'package:yamata_launcher/ui/pages/settings/settings_page.dart';
import 'package:yamata_launcher/services/assets_service.dart';
import 'package:yamata_launcher/utils/screen_helpers.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  late final List<Widget> tabs;

  final List<GlobalKey<NavigatorState>> _navigatorKeys =
      List.generate(4, (_) => GlobalKey<NavigatorState>());

  @override
  void initState() {
    super.initState();
    tabs = [
      _buildTabNavigator(
        key: _navigatorKeys[0],
        child: HomePage(),
      ),
      _buildTabNavigator(
        key: _navigatorKeys[1],
        child: LibraryPage(),
      ),
      _buildTabNavigator(
        key: _navigatorKeys[2],
        child: DownloadsPage(),
      ),
      _buildTabNavigator(
          key: _navigatorKeys[3],
          child: const SettingsPage(),
          maintainState: false),
    ];
  }

  void _popToRoot(int index) {
    _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) {
      _popToRoot(index);
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _buildTabNavigator(
      {required GlobalKey<NavigatorState> key,
      required Widget child,
      bool maintainState = true}) {
    return Navigator(
      key:
          maintainState ? key : ValueKey(DateTime.now().millisecondsSinceEpoch),
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ScreenHelpers.isSmallScreen(context);
    final isMediumScreen = ScreenHelpers.isMediumScreen(context);
    var canPop = _navigatorKeys[_currentIndex].currentState?.canPop() == false;
    const navigationItems = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.collections_bookmark, 'label': 'Library'},
      {'icon': Icons.download_sharp, 'label': 'Downloads'},
      {'icon': Icons.settings, 'label': 'Settings'},
    ];

    Widget getLogo() {
      if (isMediumScreen) {
        return AssetsService.getSvgImage("logo-orig", size: 65);
      } else {
        return Center(
          child: AssetsService.getSvgImage("logo-orig", size: 100),
        );
      }
    }

    Widget buildDesktopLayout() {
      return Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            extended: !isMediumScreen,
            minExtendedWidth: 190,
            minWidth: 60,
            indicatorColor: Colors.transparent,
            selectedLabelTextStyle: const TextStyle(color: primaryGreen),
            selectedIconTheme: const IconThemeData(color: primaryGreen),
            leading: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: getLogo(),
            ),
            destinations: navigationItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item['icon'] as IconData),
                    label: Text(item['label'] as String),
                  ),
                )
                .toList(),
            onDestinationSelected: _onTabSelected,
          ),
          const VerticalDivider(
            thickness: 1,
            width: 1,
            color: grayBorderColor,
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: tabs,
            ),
          ),
        ],
      );
    }

    return PopScope(
      canPop: canPop,
      onPopInvoked: (popHappened) {
        if (!popHappened) {
          _navigatorKeys[_currentIndex].currentState?.maybePop();
        }
      },
      child: Scaffold(
        body: isSmallScreen
            ? IndexedStack(
                index: _currentIndex,
                children: tabs,
              )
            : buildDesktopLayout(),
        bottomNavigationBar: isSmallScreen
            ? Container(
                padding: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: grayBorderColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  showUnselectedLabels: true,
                  onTap: _onTabSelected,
                  items: navigationItems
                      .map(
                        (item) => BottomNavigationBarItem(
                          icon: Icon(item['icon'] as IconData),
                          label: item['label'] as String,
                        ),
                      )
                      .toList(),
                ),
              )
            : null,
      ),
    );
  }
}
