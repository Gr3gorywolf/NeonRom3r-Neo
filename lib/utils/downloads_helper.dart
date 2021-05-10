import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_app/models/rom_download.dart';
import 'package:test_app/models/rom_info.dart';
import 'package:test_app/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/utils/files_system_helper.dart';

class DownloadsHelper {
  initDownloader() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(debug: false);
  }

  downloadRom(RomInfo rom) async {
    var downloadsPath = FileSystemHelper.downloadsPath;
    String fileName = rom.downloadLink.split('/').last;
    final taskId = await FlutterDownloader.enqueue(
      url: rom.downloadLink,
      savedDir: downloadsPath,
      fileName: Uri.decodeFull(fileName),
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
    registerRomDownload(rom, downloadsPath + "/" + Uri.decodeFull(fileName));
    catchRomPortrait(rom);
  }

  void catchRomPortrait(RomInfo romInfo) async {
    var portraitName = '${FileSystemHelper.portraitsPath}/${romInfo.name}.png';
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
                  name: oldDownload['nombre'],
                  portrait: oldDownload['portadalink'],
                  region: "--",
                  size: "--"),
              oldDownload['path']);
        }
      }
    }
  }
}
