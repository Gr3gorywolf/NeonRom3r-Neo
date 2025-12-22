import 'dart:io';

import 'package:flutter/material.dart';
import 'package:neonrom3r/app_theme.dart';
import 'package:neonrom3r/providers/download_sources_provider.dart';
import 'package:neonrom3r/providers/library_provider.dart';
import 'package:provider/provider.dart';
import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/providers/app_provider.dart';
import 'package:neonrom3r/providers/download_provider.dart';
import 'package:neonrom3r/ui/pages/downloads/downloads_page.dart';
import 'package:neonrom3r/ui/pages/emulators/emulators_page.dart';
import 'package:neonrom3r/ui/pages/home/home_page.dart';
import 'package:neonrom3r/ui/pages/settings/settings_page.dart';
import 'package:neonrom3r/ui/pages/splashcreen/splashcreen_page.dart';
import 'package:neonrom3r/ui/widgets/console_list.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:neonrom3r/services/download_service.dart';

import 'ui/pages/main_layout/main_layout.dart';

void main() {
  runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>(
          create: (context) => AppProvider(),
        ),
        ChangeNotifierProvider<DownloadProvider>(
          create: (context) => DownloadProvider(),
        ),
        ChangeNotifierProvider<DownloadSourcesProvider>(
          create: (context) => DownloadSourcesProvider(),
        ),
        ChangeNotifierProvider<LibraryProvider>(
          create: (context) => LibraryProvider(),
        ),
      ],
      builder: (context, wg) {
        return MaterialApp(
            title: 'NeonRom3r',
            theme: appTheme,
            navigatorKey: navigatorKey,
            home: Builder(
              builder: (ctx) {
                var _appProvider = AppProvider.of(ctx);
                if (_appProvider.isAppLoaded) {
                  return MainLayout();
                } else {
                  return SplashcreenPage();
                }
              },
            ));
      },
    );
  }
}
