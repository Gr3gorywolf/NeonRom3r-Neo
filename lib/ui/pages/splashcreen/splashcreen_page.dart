import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/database/app_database.dart';
import 'package:neonrom3r/providers/download_sources_provider.dart';
import 'package:neonrom3r/providers/library_provider.dart';
import 'package:neonrom3r/services/console_service.dart';
import 'package:neonrom3r/services/notifications_service.dart';
import 'package:provider/provider.dart';
import 'package:neonrom3r/providers/app_provider.dart';
import 'package:neonrom3r/providers/download_provider.dart';
import 'package:neonrom3r/utils/animation_helper.dart';
import 'package:neonrom3r/services/assets_service.dart';
import 'package:neonrom3r/constants/app_constants.dart';
import 'package:neonrom3r/services/download_service.dart';
import 'package:neonrom3r/services/files_system_service.dart';
import 'package:neonrom3r/services/rom_service.dart';

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
    await FileSystemService.initPaths();
    if (Platform.isAndroid) {
      await RomService.catchEmulatorsIntents();
    }
    await initPlugins();
    await initDb();
    await ConsoleService.loadConsoleSources();
    await Provider.of<LibraryProvider>(context, listen: false).init();
    Provider.of<DownloadProvider>(context, listen: false);
    await Provider.of<DownloadSourcesProvider>(context, listen: false)
        .initialize();
    Future.delayed(Duration(milliseconds: 2000)).then((value) =>
        {Provider.of<AppProvider>(context, listen: false).setAppLoaded(true)});
  }

  Future initPlugins() async {
    await DownloadService().initDownloader();
    await NotificationsService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: FadeOut(
      duration: Duration(milliseconds: 2000),
      manualTrigger: true,
      controller: (controller) => AnimationHelper.handleAnimation(controller),
      child: AssetsService.getImage("logo", size: 250),
    )));
  }
}
