import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/models/console.dart';
import 'package:test_app/providers/app_provider.dart';
import 'package:test_app/providers/download_provider.dart';
import 'package:test_app/ui/pages/downloads/downloads_page.dart';
import 'package:test_app/ui/pages/emulators/emulators_page.dart';
import 'package:test_app/ui/pages/roms/roms_page.dart';
import 'package:test_app/ui/pages/settings/settings_page.dart';
import 'package:test_app/ui/pages/splashcreen/splashcreen_page.dart';
import 'package:test_app/ui/widgets/console_list.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:test_app/utils/downloads_helper.dart';

import 'ui/pages/home/home_page.dart';

void main() {
  runApp(MyApp());
}

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
      ],
      builder: (context, wg) {
       return MaterialApp(
            title: 'NeonRom3r',
            theme: ThemeData(
              highlightColor: Colors.white,
              appBarTheme: AppBarTheme(
                  textTheme: TextTheme(
                      headline4: TextStyle(color: Colors.white),
                      subtitle1: TextStyle(color: Colors.white))),
              iconTheme: IconThemeData(color: Colors.white),
              inputDecorationTheme: InputDecorationTheme(
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.grey[100]),
                  helperStyle: TextStyle(color: Colors.white)),
              primarySwatch: Colors.green,
              scaffoldBackgroundColor: Colors.grey[900],
              canvasColor: Color.fromARGB(200, 0, 0, 0),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: Builder(
              builder: (ctx) {
                var _appProvider = AppProvider.of(ctx);
                if (_appProvider.isAppLoaded) {
                  return HomePage();
                } else {
                  return SplashcreenPage();
                }
              },
            ));
      },
    );
  }
}
