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

class DownloadsHelper {
  initPaths() async {
    var status = await Permission.storage.status;
    if (status.isUndetermined || status.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      if (!statuses[0].isGranted) {
        return;
      }
    }

    var paths = [
      await Constants.getDownloadsPath(),
      await Constants.getCachePath(),
      await Constants.getPortraitsPath()
    ];
    for (var path in paths) {
      if (!await Directory(path).exists()) {
        await Directory(path).create(recursive: true);
      }
    }
  }

  initDownloader() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(debug: false);
  }

  downloadRom(RomInfo rom) async {
    var downloadsPath = await Constants.getDownloadsPath();
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

  void catchRomPortrait(RomInfo romInfo) {
    var portraitName = '${Constants.getPortraitsPath()}/${romInfo.name}.png';
    if (!File(portraitName).existsSync()) {
      http.get(romInfo.portrait).then((response) {
        new File(portraitName).writeAsBytes(response.bodyBytes);
      });
    }
  }

  List<RomDownload> getDownloadedRoms() {
    var registryData = "[]";
    File registryFile = File(Constants.getDownloadRegistryFile());
    if (registryFile.existsSync()) {
      registryData = registryFile.readAsStringSync();
    } else {
      registryFile.createSync();
    }
    var registryObject = json.decode(registryData);
    List<RomDownload> downloads = [];
    for (var down in registryObject) {
      downloads.add(RomDownload.fromJson(down));
    }
    return downloads;
  }

  void registerRomDownload(RomInfo downloadedRom, String downloadedPath) {
    File registryFile = File(Constants.getDownloadRegistryFile());
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
}
