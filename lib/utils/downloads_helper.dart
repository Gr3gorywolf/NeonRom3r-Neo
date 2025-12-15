import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:neonrom3r/models/aria2c.dart';
import 'package:neonrom3r/models/download_source_rom.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:neonrom3r/models/rom_download.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/utils/consoles_helper.dart';
import 'package:neonrom3r/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:neonrom3r/utils/files_system_helper.dart';
import 'package:neonrom3r/utils/roms_helper.dart';

import 'aria2c_download_manager.dart';

class DownloadsHelper {
  initDownloader() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(debug: false);
  }

  Future<Map<String, String>> fetchDownloadHeaders(url) async {
    var client = new http.Client();
    try {
      var res = await client.head(url);
      return res.headers;
    } catch (err) {
      return new Map<String, String>();
    }
  }

  String _getFileNameFromHeaders(Map<String, String> headers) {
    if (headers.keys.contains('content-disposition')) {
      var fileNameArray = headers['content-disposition'].split('filename="');
      if (fileNameArray.length > 0) {
        fileNameArray = fileNameArray[1].split('";');
        return fileNameArray[0];
      }
    }
    return null;
  }

  downloadRom(RomInfo rom, DownloadSourceRom sourceRom) async {
    var downloadsPath = FileSystemHelper.downloadsPath + "/" + rom.console;
    if (!await Directory(downloadsPath).exists()) {
      await Directory(downloadsPath).create();
    }

    final handle = await Aria2DownloadManager.startDownload(
      romName: rom.title,
      aria2cPath: FileSystemHelper.aria2cPath + "/aria2c",
      uri: sourceRom.uris[0],
      filePathInTorrent: sourceRom.filePath,
      selectIndex: sourceRom.fileIndex,
      // OR selectIndex: 5907,
    );
    final sub = handle.events.listen((e) {
      if (e is Aria2ProgressEvent) {
        // Here’s the string you asked for (pct, up/down speeds, seeds, eta when present):
        final p = e.progress;
        final s = 'pct=${p.percent ?? "-"} '
            'dl=${p.dlSpeed ?? "-"} '
            'ul=${p.ulSpeed ?? "-"} '
            'sd=${p.seeds ?? "-"} '
            'eta=${p.eta ?? "-"}';
        print(s);
      } else if (e is Aria2LogEvent) {
        // Optional: raw logs
        print(e.line);
      } else if (e is Aria2ErrorEvent) {
        print('ERROR: ${e.message}');
      } else if (e is Aria2DoneEvent) {
        print('DONE: ${e.outputFilePath}');
      }
    });
  }

  void catchRomPortrait(RomInfo romInfo) async {
    var portraitName = '${FileSystemHelper.portraitsPath}/${romInfo.title}.png';
    if (!File(portraitName).existsSync()) {
      http.get(romInfo.portrait).then((response) {
        new File(portraitName).writeAsBytes(response.bodyBytes);
      });
    }
  }

  List<RomDownload> getDownloadedRoms() {
    var registryData = "[]";
    File registryFile = File(FileSystemHelper.downloadRegistryFile);
    if (registryFile.existsSync()) {
      registryData = registryFile.readAsStringSync();
    } else {
      return [];
    }
    var registryObject = json.decode(registryData);
    List<RomDownload> downloads = [];
    for (var down in registryObject) {
      downloads.add(RomDownload.fromJson(down));
    }
    return downloads;
  }

  void registerRomDownload(RomInfo downloadedRom, String downloadedPath) {
    File registryFile = File(FileSystemHelper.downloadRegistryFile);
    var downloads = getDownloadedRoms();
    var downloadIndex = downloads.indexWhere(
        (element) => element.downloadLink == downloadedRom.downloadLink);
    if (downloadIndex == -1) {
      downloads.add(RomDownload.fromRomInfo(downloadedRom, downloadedPath));
    } else {
      downloads[downloadIndex].filePath = downloadedPath;
    }
    var jsonData = json.encode(downloads);
    registryFile.writeAsStringSync(jsonData);
  }

  //import the downloaded roms from the old version of neonrom3r
  void importOldRoms() async {
    var registryData = "[]";
    File registryFile = File(FileSystemHelper.cachePath + "/downloads.json");
    if (registryFile.existsSync()) {
      registryData = registryFile.readAsStringSync();
      var oldDownloads = json.decode(registryData);
      for (var oldDownload in oldDownloads) {
        if (oldDownload['path'] != null) {
          registerRomDownload(
              RomInfo(
                  console: oldDownload['consola'],
                  downloadLink: oldDownload['linkdescarga'],
                  title: oldDownload['nombre'],
                  portrait: oldDownload['portadalink'],
                  region: "--",
                  size: "--"),
              oldDownload['path']);
        }
      }
    }
  }
}
