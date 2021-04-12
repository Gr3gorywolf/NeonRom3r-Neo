import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test_app/models/console.dart';
import 'package:test_app/ui/components/console_list.dart';
import 'package:test_app/ui/screens/downloads.dart';
import 'package:test_app/ui/screens/emulators.dart';
import 'package:test_app/ui/screens/roms.dart';
import 'package:test_app/routes/AppRoutes.dart';
import 'package:test_app/ui/screens/settings.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:test_app/utils/downloads_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        routes: AppRoutes().routes,
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
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          /* appBarTheme: AppBarTheme(
              color: Colors.white,
              actionsIconTheme: IconThemeData(color: Colors.green),
              iconTheme: IconThemeData(color: Colors.green),
              textTheme: TextTheme(
                  headline6: TextStyle(color: Colors.green, fontSize: 18))),*/
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.grey[900],
          canvasColor: Color.fromARGB(200, 0, 0, 0),
          //canvasColor: Colors.green,
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MainNavigation());
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
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
              icon: Icon(Icons.gamepad),
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
