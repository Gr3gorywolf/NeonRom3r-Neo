import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yamata_launcher/models/download_source.dart';
import 'package:yamata_launcher/models/download_source_rom.dart';

class DownloadSourcesRepository {
  Future<DownloadSourceWithDownloads?> fetchSource(String sourceUrl) async {
    var client = new http.Client();
    var res = await client.get(Uri.parse(sourceUrl));
    if (res.statusCode == 200) {
      var responseData = json.decode(res.body);

      List<DownloadSourceRom> downloads = (responseData['downloads'] as List)
          .map((download) => DownloadSourceRom.fromJson(download))
          .toList();
      DateTime lastDownloadDate = downloads
          .map((e) => DateTime.parse(e.uploadDate!))
          .reduce((a, b) => a.isAfter(b) ? a : b);

      return DownloadSourceWithDownloads(
          sourceInfo: DownloadSource(
              title: responseData['title'] ?? "Unknown",
              romsCount: downloads.length,
              lastUpdated: lastDownloadDate.toIso8601String()),
          downloads: downloads);
    } else {
      return null;
    }
  }
}
