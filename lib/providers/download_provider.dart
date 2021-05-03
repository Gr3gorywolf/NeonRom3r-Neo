import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:test_app/models/download_info.dart';
import 'package:test_app/models/rom_download.dart';
import 'package:test_app/models/rom_info.dart';
import 'package:test_app/utils/downloads_helper.dart';
import 'package:test_app/utils/files_system_helper.dart';

class DownloadProvider extends ChangeNotifier {
  static DownloadProvider of(BuildContext ctx) {
    return Provider.of<DownloadProvider>(ctx);
  }

  bool _isListenerRunning = false;
  List<RomDownload> _downloadRegistry = [];
  List<DownloadInfo> _downloads = [];
  List<DownloadInfo> get downloads => _downloads;

  bool isRomDownloading(RomInfo rom) {
    return !_downloads
        .where((element) =>
            element.download.downloadLink == rom.downloadLink &&
            !element.isCompleted)
        .isEmpty;
  }

  DownloadInfo getDownloadInfo(RomInfo rom) {
    try {
      var info = _downloads
          .where((element) => element.download.downloadLink == rom.downloadLink)
          .first;

      return info;
    } catch (err) {
      return null;
    }
  }

  bool isRomReadyToPlay(RomInfo download) {
    bool _isReady = false;
    var _romResults = _downloadRegistry
        .where((element) => element.downloadLink == download.downloadLink);
    if (!_romResults.isEmpty) {
      _isReady = File(_romResults.first.filePath).existsSync();
    }
    return _isReady;
  }

  initDownloadsListener() {
    if (_isListenerRunning) return;

    Timer.periodic(Duration(seconds: 1), (timer) async {
      List<DownloadInfo> _infos = [];
      var tasks = await FlutterDownloader.loadTasksWithRawQuery(
          query: "SELECT * FROM task WHERE status IN (1, 2, 6)");
      var downloads = DownloadsHelper().getDownloadedRoms();

      for (var task in tasks) {
        RomDownload rom;
        try {
          rom = downloads
              .where((element) => element.downloadLink == task.url)
              .first;
        } catch (err) {}
        if (rom != null) {
          _infos.add(DownloadInfo(
              download: rom,
              downloadId: task.taskId,
              downloadPercent: task.progress));
        }
      }
      _downloadRegistry = downloads;
      _downloads = _infos;
      notifyListeners();
    });
  }
}
