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

bool _isRomMatch(
  DownloadSourceRom sourceRom,
  RomInfo rom,
) {
  var sourceRomTitleClear = sourceRom.title_clean ?? "";
  var romTitleClear = rom.slug.replaceFirst("${rom.console}-", "");
  if (sourceRomTitleClear.isEmpty || romTitleClear.isEmpty) return false;
  if (sourceRom.console != rom.console) return false;

  if (sourceRom.title_clean == romTitleClear) {
    return true;
  }
  if (sourceRomTitleClear[0] != romTitleClear[0]) {
    return false;
  }
  if (sourceRomTitleClear.contains(romTitleClear)) {
    return true;
  }
  final normalizedRomName = RomService.normalizeRomTitle(rom.name);
  return StringHelper.hasMinConsecutiveMatch(
    sourceRomTitleClear,
    normalizedRomName,
    minLength: normalizedRomName.length,
  );
}

Map<String, List<DownloadSource>> _compileRomSourcesIsolate(
  _CompilePayload payload,
) {
  final Map<String, List<DownloadSource>> result = {};
  Stopwatch stopwatch = new Stopwatch()..start();
  print("Isolate: Compiling download sources for ${payload.roms.length} roms");
  var romConsoles = payload.roms.map((e) => e.console).toSet();

  Map<String, List<DownloadSourceWithDownloads>> sourcesByConsole = {};
  for (final console in romConsoles) {
    sourcesByConsole[console] = payload.sources.map((source) {
      return DownloadSourceWithDownloads(
          sourceInfo: source.sourceInfo,
          downloads: source.downloads!
              .where((sourceRom) => sourceRom.console == console)
              .toList());
    }).toList();
  }
  for (final rom in payload.roms) {
    var sourcesForConsole = sourcesByConsole[rom.console];
    if (sourcesForConsole == null) continue;
    for (final source in sourcesForConsole) {
      final hasMatch =
          source.downloads.any((sourceRom) => _isRomMatch(sourceRom, rom));

      if (hasMatch) {
        var foundSource = result[rom.slug];
        if (foundSource == null) {
          result[rom.slug] = [source.sourceInfo!];
          continue;
        }
        result[rom.slug] = [...foundSource, source.sourceInfo];
      } else if (result[rom.slug] == null) {
        result[rom.slug] = [];
      }
    }
  }
  print("Finished compiling download sources in isolate in "
      "${stopwatch.elapsed.inSeconds} seconds");
  return result;
}

class DownloadSourcesProvider extends ChangeNotifier {
  static DownloadSourcesProvider of(BuildContext ctx) {
    return Provider.of<DownloadSourcesProvider>(ctx);
  }

  List<DownloadSourceWithDownloads> _downloadSources = [];
  final Map<String, List<DownloadSource>> _romSources = {};
  final Set<String> _compilingRoms = {};
  bool _initialized = false;

  List<DownloadSourceWithDownloads> get downloadSources => _downloadSources;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    _downloadSources = await DownloadSourcesService.getDownloadSources();
    _initialized = true;
    notifyListeners();
  }

  bool isRomCompilingDownloadSources(String romSlug) {
    return _compilingRoms.contains(romSlug);
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
        .where((sourceRom) => _isRomMatch(sourceRom, rom))
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
        roms.where((rom) => _romSources[rom.slug] == null).toList();

    if (romsToCompile.isEmpty) return;
    _compilingRoms.addAll(romsToCompile.map((e) => e.slug));
    notifyListeners();
    final payload = _CompilePayload(
      roms: romsToCompile,
      sources: List.unmodifiable(_downloadSources),
    );
    final Map<String, List<DownloadSource>> compiled =
        await compute(_compileRomSourcesIsolate, payload);
    _romSources.addAll(compiled);
    _compilingRoms.removeAll(romsToCompile.map((e) => e.slug));
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
