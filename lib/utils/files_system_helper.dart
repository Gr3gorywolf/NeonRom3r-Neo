import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class FileSystemHelper {
  static String _rootPath = "";
  static var isDesktop =
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  //getters
  static get rootPath {
    return _rootPath;
  }

  static get cachePath {
    return _rootPath + "/.romercache";
  }

  static get downloadsPath {
    return _rootPath + "/downloaded-roms";
  }

  static get portraitsPath {
    return cachePath + "/portraits";
  }

  static get detailsCachePath {
    return cachePath + "/details-caches";
  }

  static get downloadRegistryFile {
    return cachePath + "/downloads-neo.json";
  }

  static get aria2cPath {
    return _rootPath + "/aria2c";
  }

  static get torrentsCache {
    return cachePath + "/torrents";
  }

  static get consoleSourcesPath {
    return cachePath + "/console-sources";
  }

  static get emulatorIntentsFile {
    return cachePath + "/emulatorIntents.json";
  }

  //root-path initializer
  static _initRootPath() async {
    var rootPath = "";
    if (Platform.isAndroid) {
      // try {
      //   var storageInfo = await PathProviderEx.getStorageInfo();
      //   if (storageInfo.length > 0) {
      //     rootPath = storageInfo[0].rootDir;
      //   }
      // } on PlatformException catch (er) {}
    } else if (isDesktop) {
      rootPath = Directory.current.path;
    }
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
      torrentsCache,
      consoleSourcesPath,
      detailsCachePath
    ];
    for (var path in paths) {
      if (!await Directory(path).exists()) {
        await Directory(path).create(recursive: true);
      }
    }
  }
}
