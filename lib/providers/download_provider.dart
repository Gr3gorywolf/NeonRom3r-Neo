import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'package:yamata_launcher/utils/string_helper.dart';
import 'package:toast/toast.dart';

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
      return _activeDownloadInfos
          .where((e) => e.romSlug == rom!.slug && !e.isCompleted)
          .first;
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

  abortDownload(DownloadInfo info) {
    final active = _aria2cDownloadProcesses[info.downloadId];
    print(active);
    if (active != null) {
      _activeDownloadInfos
          .removeWhere((element) => element.downloadId == info.downloadId);
      active.handle!.abort!();
      _disposeActive(info.downloadId);
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
      return;
    }

    if (event is Aria2LogEvent) {
      // if (event.line.trim().isEmpty) return;
      // info.downloadInfo = event.line;
      // _activeDownloadInfos[infoIndex].downloadInfo = event.line;
      // notifyListeners();
      return;
    }

    if (event is Aria2DoneEvent) {
      info.downloadPercent = 100;
      info.downloadInfo = 'Download completed';
      print("Download completed: ${event.outputFilePath}");
      info.downloadPercent = 100;
      info.downloadInfo = 'Download completed';
      print("Download completed: ${event.outputFilePath}");
      _activeDownloadInfos.removeAt(_activeDownloadInfos.indexOf(info));
      _registerCompletedDownload(info, rom, event.outputFilePath ?? "");

      _disposeActive(handle.id);
      notifyListeners();
      return;
    }

    if (event is Aria2ErrorEvent) {
      info.downloadInfo = 'Error: ${event.message}';
      _disposeActive(handle.id);
      Future.delayed(Duration(seconds: 2), () {
        _activeDownloadInfos.removeAt(_activeDownloadInfos.indexOf(info));
        notifyListeners();
      });
    }
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
    var notificationsEnabledSetting =
        await SettingsService().get<bool>(SettingsKeys.ENABLE_NOTIFICATIONS);
    if (notificationsEnabledSetting == true) {
      await NotificationsService.showNotification(
          title: 'Download completed',
          body: '${rom.name} has been downloaded successfully.',
          image: rom.portrait);
    }
  }

  void _disposeActive(String? id) {
    final active = _aria2cDownloadProcesses.remove(id);
    active?.sub?.cancel();
  }
}
