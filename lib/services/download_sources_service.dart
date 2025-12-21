import 'dart:convert';

import 'package:neonrom3r/models/download_source.dart';
import 'package:neonrom3r/services/cache_service.dart';
import 'package:neonrom3r/services/rom_service.dart';

const sourcesFile = "download-sources.json";

class DownloadSourcesService {
  static DownloadSourceWithDownloads parseDownloadSourceNames(
      DownloadSourceWithDownloads input) {
    input.downloads = input.downloads!.map((e) {
      e.title_clean = RomService.normalizeRomTitle(e.title!);

      return e;
    }).toList();
    return input;
  }
}
