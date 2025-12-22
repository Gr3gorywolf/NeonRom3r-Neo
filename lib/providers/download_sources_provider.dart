import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:neonrom3r/models/download_source_rom.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/services/download_sources_service.dart';
import 'package:neonrom3r/services/rom_service.dart';
import 'package:neonrom3r/utils/string_helper.dart';
import 'package:provider/provider.dart';
import 'package:neonrom3r/models/download_source.dart';
import 'package:neonrom3r/services/cache_service.dart';

class DownloadSourcesProvider extends ChangeNotifier {
  static DownloadSourcesProvider of(BuildContext ctx) {
    return Provider.of<DownloadSourcesProvider>(ctx);
  }

  List<DownloadSourceWithDownloads> _downloadSources = [];
  final Map<String, List<DownloadSource>> _romSources = {};

  bool _initialized = false;

  List<DownloadSourceWithDownloads> get downloadSources => _downloadSources;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    _downloadSources = await DownloadSourcesService.getDownloadSources();
    _initialized = true;
    notifyListeners();
  }

  List<DownloadSourceRom> _findMatches(
    DownloadSourceWithDownloads source,
    RomInfo rom,
  ) {
    final normalizedRomName = RomService.normalizeRomTitle(rom.name);

    return source.downloads
        .where(
          (sourceRom) =>
              sourceRom.console == rom.console &&
              StringHelper.hasMinConsecutiveMatch(
                sourceRom.title_clean!,
                normalizedRomName,
                minLength: normalizedRomName.length,
              ),
        )
        .toList();
  }

  List<DownloadSourceWithDownloads> findRomSourcesWithDownloads(RomInfo rom) {
    return _downloadSources
        .map((source) {
          final matches = _findMatches(source, rom);
          if (matches.isEmpty) return null;
          return DownloadSourceWithDownloads(
            sourceInfo: source.sourceInfo,
            downloads: matches,
          );
        })
        .whereType<DownloadSourceWithDownloads>()
        .toList();
  }

  List<DownloadSource> getRomSources(String romSlug) {
    return _romSources[romSlug] ?? [];
  }

  void compileRomSources(List<RomInfo> roms) {
    print("Compiling rom sources for ${roms.length} roms...");

    for (final rom in roms) {
      if (_romSources.containsKey(rom.slug)) continue;

      for (final source in _downloadSources) {
        final matches = _findMatches(source, rom);
        if (matches.isEmpty) continue;

        _romSources.putIfAbsent(rom.slug!, () => []).add(source.sourceInfo);
      }
    }

    notifyListeners();
    print("Compiled rom sources for ${roms.length} roms...");
  }

  // Mutations
  void addDownloadSource(DownloadSourceWithDownloads source) {
    final parsed = DownloadSourcesService.parseDownloadSourceNames(source);

    final index = _downloadSources.indexOf(parsed);
    if (index != -1) {
      _downloadSources[index] = parsed;
    } else {
      _downloadSources.add(parsed);
      DownloadSourcesService.saveDownloadSource(parsed);
    }
    _romSources.clear();
    notifyListeners();
  }

  void removeDownloadSource(DownloadSourceWithDownloads source) {
    _downloadSources.remove(source);
    _romSources.clear();
    DownloadSourcesService.deleteDownloadSource(source);
    notifyListeners();
  }
}
