import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test_app/models/console.dart';
import 'package:test_app/ui/pages/downloads/downloads_page.dart';
import 'package:test_app/ui/pages/emulators/emulators_page.dart';
import 'package:test_app/ui/pages/roms/roms_page.dart';
import 'package:test_app/ui/pages/settings/settings_page.dart';
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
        home: HomePage());
  }
}


/*
class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlugins();
  }

  void initPlugins() async {
    if (Platform.isAndroid) {
      DownloadsHelper().initPaths();
      DownloadsHelper().initDownloader();
    }
  }

  @override
  Widget build(BuildContext context) {
    
  }
}
*/