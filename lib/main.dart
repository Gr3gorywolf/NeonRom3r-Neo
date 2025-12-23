import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yamata_launcher/app_theme.dart';
import 'package:yamata_launcher/providers/download_sources_provider.dart';
import 'package:yamata_launcher/providers/library_provider.dart';
import 'package:provider/provider.dart';
import 'package:yamata_launcher/models/console.dart';
import 'package:yamata_launcher/providers/app_provider.dart';
import 'package:yamata_launcher/providers/download_provider.dart';
import 'package:yamata_launcher/ui/pages/downloads/downloads_page.dart';
import 'package:yamata_launcher/ui/pages/library/library_page.dart';
import 'package:yamata_launcher/ui/pages/home/home_page.dart';
import 'package:yamata_launcher/ui/pages/settings/settings_page.dart';
import 'package:yamata_launcher/ui/pages/splashcreen/splashcreen_page.dart';
import 'package:yamata_launcher/ui/widgets/console_list.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:yamata_launcher/services/download_service.dart';

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
            title: 'yamata_launcher',
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
