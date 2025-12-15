import 'dart:convert';

import 'package:neonrom3r/models/download_source.dart';
import 'package:neonrom3r/utils/cache_helper.dart';
import 'package:neonrom3r/utils/roms_helper.dart';

const sourcesFile = "download-sources.json";

class DownloadSourcesHelper {
  static DownloadSourceWithDownloads parseDownloadSourceNames(
      DownloadSourceWithDownloads input) {
    input.downloads = input.downloads.map((e) {
      e.title_clean = RomsHelper.normalizeRomTitle(e.title);

      return e;
    }).toList();
    return input;
  }
}
