import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/providers/app_provider.dart';
import 'package:test_app/utils/assets_helper.dart';
import 'package:test_app/utils/constants.dart';
import 'package:test_app/utils/downloads_helper.dart';
import 'package:test_app/utils/files_system_helper.dart';

class SplashcreenPage extends StatefulWidget {
  @override
  _SplashcreenPageState createState() => _SplashcreenPageState();
}

class _SplashcreenPageState extends State<SplashcreenPage> {
  @override
  void initState() {
    super.initState();
    initApp();
  }

  initApp() async {
    if (Platform.isAndroid) {
      await FileSystemHelper.initPaths();
      await initPlugins();
    }
    Provider.of<AppProvider>(context, listen: false).setAppLoaded(true);
  }

  void initPlugins() async {
    DownloadsHelper().initDownloader();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: FadeOut(
      duration: Duration(milliseconds: 2000),
      manualTrigger: true,
      controller: (controller) {
        controller.forward();
        controller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            controller.reverse();
          }
          if (status == AnimationStatus.dismissed) {
            controller.forward();
          }
        });
      },
      child: AssetsHelper.getImage("logo", size: 250),
    )));
  }
}
