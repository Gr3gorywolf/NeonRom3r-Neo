import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:neonrom3r/models/download_source_rom.dart';
import 'package:neonrom3r/models/download_source_rom.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/utils/download_sources_helper.dart';
import 'package:neonrom3r/utils/roms_helper.dart';
import 'package:neonrom3r/utils/string_helper.dart';
import 'package:provider/provider.dart';
import 'package:neonrom3r/models/download_source.dart';
import 'package:neonrom3r/utils/cache_helper.dart';

const sourcesFile = "download-sources.json";

class DownloadSourcesProvider extends ChangeNotifier {
  static DownloadSourcesProvider of(BuildContext ctx) {
    return Provider.of<DownloadSourcesProvider>(ctx);
  }

  List<DownloadSourceWithDownloads> _downloadSources = [];
  List<DownloadSourceWithDownloads> get downloadSources => _downloadSources;

  bool _initialized = false;
  bool get initialized => _initialized;
  Future<void> initDownloadSources() async {
    if (_initialized) return;

    final file = CacheHelper.retrieveCacheFile(sourcesFile);
    if (file == null) {
      _initialized = true;
      return;
    }

    setDownloadSources((json.decode(file) as List)
        .map((e) => DownloadSourceWithDownloads.fromJson(e))
        .toList());

    _initialized = true;
    notifyListeners();
  }

  Future<void> saveDownloadSources() async {
    final jsonData = json.encode(
      _downloadSources.map((e) => e.toJson()).toList(),
    );
    await CacheHelper.writeCacheFile(sourcesFile, jsonData);
  }

  List<DownloadSourceWithDownloads> findDownloadSources(RomInfo rom) {
    final normalizedRomName = RomsHelper.normalizeRomTitle(rom.title);
    final List<DownloadSourceWithDownloads> results = [];

    for (final source in _downloadSources) {
      final matches = source.downloads.where((sourceRom) {
        return StringHelper.hasMinConsecutiveMatch(
                sourceRom.title_clean, normalizedRomName,
                minLength: normalizedRomName.length) &&
            sourceRom.console == rom.console;
      }).toList();

      if (matches.isNotEmpty) {
        results.add(DownloadSourceWithDownloads(
          sourceInfo: source.sourceInfo,
          downloads: matches,
        ));
      }
    }

    return results;
  }

  void setDownloadSources(List<DownloadSourceWithDownloads> sources) {
    _downloadSources = sources
        .map((e) => DownloadSourcesHelper.parseDownloadSourceNames(e))
        .toList();
    notifyListeners();
    saveDownloadSources();
  }

  void addDownloadSource(DownloadSourceWithDownloads source) {
    DownloadSourceWithDownloads parsedSource =
        DownloadSourcesHelper.parseDownloadSourceNames(source);
    if (downloadSources.contains(parsedSource)) {
      downloadSources[downloadSources.indexOf(parsedSource)] = parsedSource;
      notifyListeners();
      saveDownloadSources();
      return;
    }
    _downloadSources.add(parsedSource);
    notifyListeners();
    saveDownloadSources();
  }

  void removeDownloadSource(DownloadSourceWithDownloads source) {
    _downloadSources.remove(source);
    notifyListeners();
    saveDownloadSources();
  }

  void clear() {
    _downloadSources.clear();
    notifyListeners();
    saveDownloadSources();
  }
}
