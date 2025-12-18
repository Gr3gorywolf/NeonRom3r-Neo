import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/providers/download_sources_provider.dart';
import 'package:neonrom3r/utils/consoles_helper.dart';
import 'package:provider/provider.dart';
import 'package:neonrom3r/providers/app_provider.dart';
import 'package:neonrom3r/providers/download_provider.dart';
import 'package:neonrom3r/utils/animation_helper.dart';
import 'package:neonrom3r/utils/assets_helper.dart';
import 'package:neonrom3r/utils/constants.dart';
import 'package:neonrom3r/utils/downloads_helper.dart';
import 'package:neonrom3r/utils/files_system_helper.dart';
import 'package:neonrom3r/utils/roms_helper.dart';

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
    await FileSystemHelper.initPaths();
    if (Platform.isAndroid) {
      await initPlugins();
      await RomsHelper.catchEmulatorsIntents();
      DownloadsHelper().importOldRoms();
    }
    await ConsolesHelper.loadConsoleSources();
    Provider.of<DownloadProvider>(context, listen: false).initDownloads();
    await Provider.of<DownloadSourcesProvider>(context, listen: false)
        .initDownloadSources();
    Future.delayed(Duration(milliseconds: 2000)).then((value) =>
        {Provider.of<AppProvider>(context, listen: false).setAppLoaded(true)});
  }

  Future initPlugins() async {
    DownloadsHelper().initDownloader();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: FadeOut(
      duration: Duration(milliseconds: 2000),
      manualTrigger: true,
      controller: (controller) => AnimationHelper.handleAnimation(controller),
      child: AssetsHelper.getImage("logo", size: 250),
    )));
  }
}
