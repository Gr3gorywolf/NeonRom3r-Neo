import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileSystemService {
  static String _rootPath = "";
  static String _appDocPath = "";
  static var isDesktop =
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  //getters
  static get rootPath {
    return _rootPath;
  }

  static get cachePath {
    return _appDocPath + "/cache";
  }

  static get downloadsPath {
    return _rootPath + "/downloads";
  }

  static get portraitsPath {
    return cachePath + "/portraits";
  }

  static get fetchCachePath {
    return cachePath + "/fetch-cache";
  }

  static get aria2cPath {
    return _rootPath + "/aria2c";
  }

  static get torrentsCachePath {
    return cachePath + "/torrents";
  }

  static get downloadSourcesPath {
    return _appDocPath + "/download-sources";
  }

  static get consoleSourcesPath {
    return _appDocPath + "/console-sources";
  }

  static get databaseFilePath {
    return _appDocPath + "/database.db";
  }

  static get downloadRegistryFilePath {
    return cachePath + "/downloads-neo.json";
  }

  static get emulatorIntentsFilePath {
    return _appDocPath + "/emulatorIntents.json";
  }

  //root-path initializer
  static _initRootPath() async {
    var rootPath = "";
    rootPath = Directory.current.path;
    _appDocPath = (await getApplicationSupportDirectory()).path;
    print("Root path initialized to: " + rootPath);
    _rootPath = rootPath;
  }

  //initializer
  static initPaths() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (status.isRestricted || status.isDenied) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
        ].request();
        var status = statuses[Permission.storage]!;
        if (!status.isGranted) {
          return;
        }
      }
    }
    await _initRootPath();

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
