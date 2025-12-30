import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yamata_launcher/constants/files_constants.dart';
import 'package:yamata_launcher/constants/settings_constants.dart';
import 'package:yamata_launcher/database/app_database.dart';
import 'package:yamata_launcher/database/daos/library_dao.dart';
import 'package:yamata_launcher/main.dart';
import 'package:yamata_launcher/models/rom_library_item.dart';
import 'package:yamata_launcher/providers/library_provider.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/services/aria2c/aria2c_download_manager.dart';
import 'package:yamata_launcher/services/notifications_service.dart';
import 'package:yamata_launcher/services/settings_service.dart';
import 'package:provider/provider.dart';

import 'package:yamata_launcher/models/aria2c.dart';
import 'package:yamata_launcher/models/download_info.dart';
import 'package:yamata_launcher/models/download_source_rom.dart';
import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/services/download_service.dart';
import 'package:yamata_launcher/services/files_system_service.dart';
import 'package:yamata_launcher/services/extraction_service.dart';
import 'package:yamata_launcher/utils/string_helper.dart';
import 'package:toast/toast.dart';
import 'package:yamata_launcher/utils/system_helpers.dart';

class _ActiveAria2Download {
  RomInfo? rom;
  DownloadSourceRom? source;
  Aria2DownloadHandle? handle;
  StreamSubscription? sub;

  _ActiveAria2Download({
    this.rom,
    this.source,
    this.handle,
    this.sub,
  });
}

class DownloadProvider extends ChangeNotifier {
  static DownloadProvider of(BuildContext ctx) {
    return Provider.of<DownloadProvider>(ctx);
  }

  final Map<String?, _ActiveAria2Download> _aria2cDownloadProcesses = {};
  final List<DownloadInfo> _activeDownloadInfos = [];

  List<DownloadInfo> get activeDownloadInfos => _activeDownloadInfos;

  /// ========================================================================
  /// Public API
  /// ========================================================================

  bool isRomDownloading(RomInfo rom) {
    return activeDownloadInfos.any((d) => d.romSlug == rom.slug);
  }

  DownloadInfo? getDownloadInfo(RomInfo? rom) {
    try {
      return _activeDownloadInfos.where((e) => e.romSlug == rom!.slug).first;
    } catch (_) {
      return null;
    }
  }

  /// ========================================================================
  /// Start download
  /// ========================================================================

  Future<void> addRomDownloadToQueue(
    RomInfo rom,
    DownloadSourceRom source,
    Aria2DownloadHandle handle,
  ) async {
    final downloadId = handle.id;
    final info = DownloadInfo(
      romSlug: rom.slug,
      downloadId: downloadId,
      downloadPercent: 0,
      downloadInfo: 'Starting download...',
    );

    if (Platform.isAndroid) {
      NotificationsService.showNotification(
        title: 'Downloading ${rom.name}',
        body: 'Starting download...',
        image: rom.portrait,
        progressPercent: info.downloadPercent,
        tag: rom.slug,
      );
    }

    _activeDownloadInfos.add(info);
    final sub = handle.events!.listen((event) {
      _handleAria2Event(
        event,
        rom,
        source,
        handle,
        info,
      );
    });

    _aria2cDownloadProcesses[downloadId] = _ActiveAria2Download(
      rom: rom,
      source: source,
      handle: handle,
      sub: sub,
    );

    notifyListeners();
  }

  abortDownload(DownloadInfo info) async {
    if (info.isUncompressing) {
      await ExtractionService.cancel(info.downloadId ?? "");
      _activeDownloadInfos
          .removeWhere((element) => element.downloadId == info.downloadId);
      return;
    }
    final active = _aria2cDownloadProcesses[info.downloadId];
    if (active != null) {
      _activeDownloadInfos
          .removeWhere((element) => element.downloadId == info.downloadId);
      active.handle!.abort!();
      _disposeActive(info.downloadId);
      if (Platform.isAndroid) {
        print("Cancelling notification for tag: ${info.romSlug}");
        NotificationsService.cancelNotificationByTag(info.romSlug);
      }
      notifyListeners();
    }
  }

  /// ========================================================================
  /// Event handling
  /// ========================================================================

  void _handleAria2Event(
    Aria2Event event,
    RomInfo rom,
    DownloadSourceRom source,
    Aria2DownloadHandle handle,
    DownloadInfo info,
  ) {
    var infoIndex = _activeDownloadInfos
        .indexWhere((element) => element.downloadId == info.downloadId);
    if (event is Aria2ProgressEvent) {
      final p = event.progress;

      info.downloadPercent =
          int.tryParse(p.percent?.replaceAll('%', '') ?? '0');

      info.downloadInfo = _formatProgressInfo(p);
      print("Download info: ${info.downloadInfo}");
      notifyListeners();
      if (Platform.isAndroid) {
        NotificationsService.showNotification(
          title: 'Downloading ${rom.name}',
          body: '${info.downloadInfo}',
          image: rom.portrait,
          progressPercent: info.downloadPercent,
          tag: rom.slug,
        );
      }
      return;
    }

    if (event is Aria2LogEvent) {
      // if (event.line.trim().isEmpty) return;
      // info.downloadInfo = event.line;
      // _activeDownloadInfos[infoIndex].downloadInfo = event.line;
      // notifyListeners();
      print("event.line: ${event.line}");
      return;
    }

    if (event is Aria2DoneEvent) {
      info.downloadPercent = 100;
      info.downloadInfo = 'Download completed';
      print("Download completed: ${event.outputFilePath}");
      info.downloadPercent = 100;
      info.downloadInfo = 'Download completed';
      print("Download completed: ${event.outputFilePath}");
      _registerCompletedDownload(info, rom, event.outputFilePath ?? "");
      _disposeActive(handle.id);
      notifyListeners();
      return;
    }

    if (event is Aria2ErrorEvent) {
      info.downloadInfo = 'Error: ${event.message}';
      print("Download error: ${event.message}");
      _disposeActive(handle.id);
      Future.delayed(Duration(seconds: 2), () {
        _activeDownloadInfos.removeAt(_activeDownloadInfos.indexOf(info));
        notifyListeners();
        NotificationsService.showNotification(
          title: 'Failed to download ${rom.name}',
          body:
              '${StringHelper.truncateWithEllipsis(event.message ?? "Unknown error", 100)}',
          image: rom.portrait,
          tag: rom.slug,
        );
      });
    }
  }

  void _registerCompletedDownload(
      DownloadInfo download, RomInfo rom, String path) async {
    BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    var libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
    var libraryItem = libraryProvider.getLibraryItem(rom.slug);
    if (libraryItem == null) {
      libraryItem = RomLibraryItem(
        rom: rom,
        filePath: path,
        downloadedAt: DateTime.now(),
        addedAt: DateTime.now(),
      );
      await libraryProvider.addLibraryItem(libraryItem);
      return;
    }
    libraryItem.filePath = path;
    libraryItem.downloadedAt = DateTime.now();
    await libraryProvider.updateLibraryItem(libraryItem);
    await NotificationsService.showNotification(
      title: 'Download completed',
      body: '${rom.name} has been downloaded successfully.',
      image: rom.portrait,
      tag: rom.slug,
    );
    var fileExtension = SystemHelpers.getFileExtension(path).toLowerCase();
    var extractionEnabled =
        SettingsService().get<bool>(SettingsKeys.ENABLE_EXTRACTION);
    if (extractionEnabled == true &&
        VALID_COMPRESSED_EXTENSIONS.contains(fileExtension)) {
      _handleUncompression(download, rom, path);
    } else {
      _activeDownloadInfos.removeAt(_activeDownloadInfos.indexOf(download));
    }
  }

  void _handleUncompression(
    DownloadInfo download,
    RomInfo rom,
    String path,
  ) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final libraryProvider =
        Provider.of<LibraryProvider>(context, listen: false);

    final libraryItem = libraryProvider.getLibraryItem(download.romSlug);

    final file = File(path);
    final parentDir = file.parent;

    final (id, progressStream) = await ExtractionService.enqueueExtraction(
      input: file,
      output: parentDir,
      extractionId: download.downloadId,
    );

    progressStream.listen((progress) {
      download.isUncompressing = true;

      if (progress < 0) {
        _setQueuedState(download);
      } else {
        _setUncompressingState(
          download: download,
          progress: progress,
          rom: rom,
        );

        if (progress >= 100) {
          _finishUncompression(
            download: download,
            rom: rom,
            zipFile: file,
            outputDir: parentDir,
            libraryItem: libraryItem,
            libraryProvider: libraryProvider,
          );
        }
      }

      notifyListeners();
    });
  }

  void _disposeActive(String? id) {
    final active = _aria2cDownloadProcesses.remove(id);
    active?.sub?.cancel();
  }

  /// ========================================================================
  /// Helpers
  /// ========================================================================

  String _formatProgressInfo(Aria2Progress p) {
    final parts = <String>[];

    if (p.downloaded != null && p.total != null) {
      parts.add('${p.downloaded} / ${p.total}');
    }

    if (p.dlSpeed != null) {
      parts.add('↓ ${p.dlSpeed}');
    }

    if (p.ulSpeed != null) {
      parts.add('↑ ${p.ulSpeed}');
    }

    if (p.seeds != null) {
      parts.add('Seeds ${p.seeds}');
    }

    if (p.eta != null) {
      parts.add('ETA ${p.eta}');
    }

    if (p.dlSpeed != null &&
        [p.ulSpeed, p.seeds, p.eta].every((e) => e == null)) {
      return 'Fetching metadata...';
    }

    return parts.join(' • ').replaceAll("[", "").replaceAll("]", "");
  }

  void _setQueuedState(DownloadInfo download) {
    download.downloadPercent = 0;
    download.downloadInfo = "Queued for uncompression...";
  }

  void _setUncompressingState({
    required DownloadInfo download,
    required double progress,
    required RomInfo rom,
  }) {
    download.downloadPercent = progress.toInt();
    download.downloadInfo = "Uncompressing...";

    if (Platform.isAndroid) {
      NotificationsService.showNotification(
        title: 'Extracting ${rom.name}',
        body: download.downloadInfo ?? "",
        image: rom.portrait,
        progressPercent: download.downloadPercent,
        tag: rom.slug,
      );
    }
  }

  void _finishUncompression({
    required DownloadInfo download,
    required RomInfo rom,
    required File zipFile,
    required Directory outputDir,
    required RomLibraryItem? libraryItem,
    required LibraryProvider libraryProvider,
  }) {
    download.downloadPercent = 100;
    download.downloadInfo = "Extraction completed.";

    // look for extracted ROM
    for (var file in outputDir.listSync()) {
      final ext = file.path.split('.').last.toLowerCase();

      if (VALID_ROM_EXTENSIONS.contains(ext)) {
        if (libraryItem != null) {
          libraryItem.filePath = file.path;
          libraryProvider.updateLibraryItem(libraryItem);
        }

        // delete zip
        if (zipFile.existsSync()) {
          zipFile.deleteSync();
        }

        break;
      }
    }

    NotificationsService.showNotification(
      title: download.downloadInfo ?? "",
      body: '${rom.name} is ready to play!',
      image: rom.portrait,
      tag: rom.slug,
    );

    _activeDownloadInfos.remove(download);
  }
}
