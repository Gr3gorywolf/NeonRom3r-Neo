import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/main.dart';
import 'package:neonrom3r/services/alerts_service.dart';
import 'package:neonrom3r/services/aria2c/aria2c_download_manager.dart';
import 'package:provider/provider.dart';

import 'package:neonrom3r/models/aria2c.dart';
import 'package:neonrom3r/models/download_info.dart';
import 'package:neonrom3r/models/download_source_rom.dart';
import 'package:neonrom3r/models/rom_download.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/services/download_service.dart';
import 'package:neonrom3r/services/files_system_service.dart';
import 'package:neonrom3r/utils/string_helper.dart';
import 'package:toast/toast.dart';

class DownloadProvider extends ChangeNotifier {
  static DownloadProvider of(BuildContext ctx) {
    return Provider.of<DownloadProvider>(ctx);
  }

  final Map<String?, _ActiveAria2Download> _aria2cDownloadProcesses = {};
  final List<DownloadInfo> _activeDownloadInfos = [];
  List<RomDownload?> _downloadHistory = [];

  List<DownloadInfo> get activeDownloadInfos => _activeDownloadInfos;
  List<RomDownload> get downloadsRegistry {
    final downloadingRoms =
        _activeDownloadInfos.map((e) => e.download).toList();
    var downloadHistory = _downloadHistory
        .where((d) => !downloadingRoms
            .any((dr) => dr!.name == d!.name && dr.console == d.console))
        .toList();
    return [...downloadHistory, ...downloadingRoms]
        .where((element) => element != null)
        .cast<RomDownload>()
        .toList();
  }

  /// ========================================================================
  /// Public API
  /// ========================================================================

  bool isRomDownloading(RomInfo rom) {
    return activeDownloadInfos.any((d) => d.download!.isRomInfoEqual(rom));
  }

  DownloadInfo? getDownloadInfo(RomInfo? rom) {
    try {
      return _activeDownloadInfos
          .where((e) => e.download!.isRomInfoEqual(rom!) && !e.isCompleted)
          .first;
    } catch (_) {
      return null;
    }
  }

  RomDownload? getDownloadedRomInfo(RomInfo rom) {
    try {
      return _downloadHistory.where((e) => e!.isRomInfoEqual(rom)).first;
    } catch (_) {
      return null;
    }
  }

  bool isRomReadyToPlay(RomInfo rom) {
    final downloaded = getDownloadedRomInfo(rom);
    if (downloaded == null) return false;
    return Directory(downloaded.filePath!).existsSync() ||
        File(downloaded.filePath!).existsSync();
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

    final romDownload = RomDownload(
      name: rom.name,
      portrait: rom.portrait,
      downloadLink: downloadId,
      console: rom.console,
      size: source.fileSize,
    );

    final info = DownloadInfo(
      download: romDownload,
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
      info.download!.filePath = event.outputFilePath;
      _activeDownloadInfos.removeAt(_activeDownloadInfos.indexOf(info));
      _registerCompletedDownload(info.download, rom);

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

    return parts.join(' • ').replaceAll("[", "").replaceAll("]", "");
  }

  void initDownloads() {
    _downloadHistory = DownloadService().getDownloadedRoms();
    print(
        "Download registry initialized with ${_downloadHistory.length} items");
  }

  void _registerCompletedDownload(RomDownload? download, RomInfo rom) {
    _downloadHistory = DownloadService().getDownloadedRoms();

    final exists = _downloadHistory.any((e) => e!.isRomInfoEqual(rom));

    if (!exists) {
      _downloadHistory.add(download);
      DownloadService().registerRomDownload(rom, download!.filePath);
    }
  }

  void _disposeActive(String? id) {
    final active = _aria2cDownloadProcesses.remove(id);
    active?.sub?.cancel();
  }
}

/// ============================================================================
/// Internal active download wrapper
/// ============================================================================

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
