import 'dart:io';

import 'package:flutter/services.dart';
import 'package:yamata_launcher/constants/settings_constants.dart';
import 'package:yamata_launcher/services/settings_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yamata_launcher/utils/system_helpers.dart';

class FileSystemService {
  static String _rootPath = "";
  static String _appSupportPath = "";
  static String? _downloadsPath;
  static String? _appDocsPath = "";
  static var isDesktop =
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  //getters
  static get rootPath {
    return _rootPath;
  }

  static get cachePath {
    return _appSupportPath + "/cache";
  }

  static get downloadsPath {
    if (_downloadsPath != null) {
      return _downloadsPath!;
    }
    return _rootPath + "/downloads";
  }

  static get portraitsPath {
    return cachePath + "/portraits";
  }

  static get fetchCachePath {
    return cachePath + "/fetch-cache";
  }

  static get aria2cPath {
    return (_appSupportPath ?? "") +
        "/aria2c/" +
        SystemHelpers.aria2cOutputBinary;
  }

  static get torrentsCachePath {
    return cachePath + "/torrents";
  }

  static get downloadSourcesPath {
    return _appSupportPath + "/download-sources";
  }

  static get consoleSourcesPath {
    return _appSupportPath + "/console-sources";
  }

  static get databaseFilePath {
    return _appSupportPath + "/database.db";
  }

  static get downloadRegistryFilePath {
    return cachePath + "/downloads-neo.json";
  }

  static get emulatorIntentsFilePath {
    return _appSupportPath + "/emulatorIntents.json";
  }

  static setupDownloadsPath() async {
    var path = await SettingsService().get<String>(SettingsKeys.DOWNLOAD_PATH);
    if (path.isEmpty) {
      _downloadsPath = (await getDownloadsDirectory())?.path ?? null;
      await SettingsService()
          .set<String>(SettingsKeys.DOWNLOAD_PATH, downloadsPath);
      return;
    }
    if (path.isNotEmpty) {
      if (Directory(path).existsSync()) {
        _downloadsPath = path;
        return;
      }
    }
  }

  static setupAria2c() async {
    var aria2cDir = Directory("${_appSupportPath}/aria2c");
    final file = File("${aria2cDir.path}/${SystemHelpers.aria2cOutputBinary}");
    if (await file.exists()) {
      return;
    }
    if (aria2cDir.existsSync() == false) {
      await aria2cDir.create(recursive: true);
    }

    final byteData =
        await rootBundle.load("assets/bin/${SystemHelpers.aria2cAssetBinary}");
    final bytes = byteData.buffer.asUint8List();
    await file.writeAsBytes(bytes, flush: true);
    if (!Platform.isWindows) {
      await Process.run('chmod', ['+x', file.path]);
    }

    return file.path;
  }

  static Future<bool> deleteCachePath() async {
    try {
      var dir = Directory(cachePath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      await dir.create();
      return true;
    } catch (e) {
      print("Error deleting cache path: " + e.toString());
      return false;
    }
  }

  //root-path initializer
  static _initRootPath() async {
    var rootPath = "";
    rootPath = Directory.current.path;
    _appSupportPath = (await getApplicationSupportDirectory()).path;
    _appDocsPath = (await getApplicationDocumentsDirectory()).path;
    print("Root path initialized to: " + rootPath);
    _rootPath = rootPath;
  }

  //initializer
  static initPaths() async {
    await _initRootPath();
    await setupDownloadsPath();
    await setupAria2c();

    var paths = [
      downloadsPath,
      cachePath,
      portraitsPath,
      torrentsCachePath,
      downloadSourcesPath,
      consoleSourcesPath,
      fetchCachePath
    ];
    for (var path in paths) {
      if (!await Directory(path).exists()) {
        await Directory(path).create(recursive: true);
      }
    }
  }
}
