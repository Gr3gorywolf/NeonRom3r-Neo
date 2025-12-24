import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:yamata_launcher/models/download_source_rom.dart';
import 'package:yamata_launcher/models/download_source.dart';
import 'package:yamata_launcher/models/rom_info.dart';

import 'package:yamata_launcher/services/download_sources_service.dart';
import 'package:yamata_launcher/services/rom_service.dart';
import 'package:yamata_launcher/utils/string_helper.dart';

class _CompilePayload {
  final List<RomInfo> roms;
  final List<DownloadSourceWithDownloads> sources;

  _CompilePayload({
    required this.roms,
    required this.sources,
  });
}

Map<String, List<DownloadSource>> _compileRomSourcesIsolate(
  _CompilePayload payload,
) {
  final Map<String, List<DownloadSource>> result = {};

  for (final rom in payload.roms) {
    final normalizedRomName = RomService.normalizeRomTitle(rom.name);

    for (final source in payload.sources) {
      final hasMatch = source.downloads.any(
        (sourceRom) =>
            sourceRom.console == rom.console &&
            StringHelper.hasMinConsecutiveMatch(
              sourceRom.title_clean!,
              normalizedRomName,
              minLength: normalizedRomName.length,
            ),
      );

      if (hasMatch) {
        result.putIfAbsent(rom.slug!, () => []).add(source.sourceInfo);
      }
    }
  }

  return result;
}

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

  List<DownloadSource> getRomSources(String romSlug) {
    return _romSources[romSlug] ?? [];
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

  Future<void> compileRomDownloadSources(List<RomInfo> roms) async {
    if (_downloadSources.isEmpty || roms.isEmpty) return;

    final romsToCompile =
        roms.where((rom) => !_romSources.containsKey(rom.slug)).toList();

    if (romsToCompile.isEmpty) return;

    final payload = _CompilePayload(
      roms: romsToCompile,
      sources: List.unmodifiable(_downloadSources),
    );

    final Map<String, List<DownloadSource>> compiled =
        await compute(_compileRomSourcesIsolate, payload);

    _romSources.addAll(compiled);

    notifyListeners();
  }

  Future<bool> setDownloadSource(DownloadSourceWithDownloads source) async {
    final parsed = DownloadSourcesService.parseDownloadSourceNames(source);

    final validFile = await DownloadSourcesService.saveDownloadSource(parsed);

    if (!validFile) return false;

    final index = _downloadSources.indexWhere(
      (s) => s.sourceInfo.title == parsed.sourceInfo!.title,
    );

    if (index != -1) {
      _downloadSources[index] = parsed;
    } else {
      _downloadSources.add(parsed);
    }

    _romSources.clear();
    notifyListeners();
    return true;
  }

  void removeDownloadSource(DownloadSourceWithDownloads source) {
    _downloadSources.remove(source);
    _romSources.clear();
    DownloadSourcesService.deleteDownloadSource(source);
    notifyListeners();
  }
}
