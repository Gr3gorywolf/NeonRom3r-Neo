import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_theme_dark.dart';
import '../../services/assets_service.dart';
import '../../utils/screen_helpers.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  static const _routes = [
    '/home',
    '/library',
    '/downloads',
    '/settings',
  ];

  int _locationToIndex(String location) {
    return _routes.indexWhere((e) => location.startsWith(e));
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    final isSmallScreen = ScreenHelpers.isSmallScreen(context);
    final isMediumScreen = ScreenHelpers.isMediumScreen(context);

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
            selectedIndex: currentIndex,
            extended: !isMediumScreen,
            minExtendedWidth: 190,
            minWidth: 60,
            indicatorColor: Colors.transparent,
            selectedLabelTextStyle:
                TextStyle(color: Theme.of(context).colorScheme.primary),
            selectedIconTheme:
                IconThemeData(color: Theme.of(context).colorScheme.primary),
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
            onDestinationSelected: (index) {
              context.go(_routes[index]);
            },
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          Expanded(child: child),
        ],
      );
    }

    return Scaffold(
      body: isSmallScreen ? child : buildDesktopLayout(),
      bottomNavigationBar: isSmallScreen
          ? Container(
              padding: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                showUnselectedLabels: true,
                onTap: (index) {
                  context.go(_routes[index]);
                },
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
    );
  }
}
