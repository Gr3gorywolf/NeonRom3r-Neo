import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:permission_handler/permission_handler.dart';

class FileSystemHelper {
  static String _rootPath = "";
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
    return _rootPath + "/portraits";
  }

  static get downloadRegistryFile {
    return _rootPath + "/downloads.json";
  }

  //root-path initializer
  static _initRootPath() async {
    var rootPath = "";
    try {
      var storageInfo = await PathProviderEx.getStorageInfo();
      if (storageInfo.length > 0) {
        rootPath = storageInfo[0].rootDir;
      }
    } on PlatformException {}
    _rootPath = rootPath;
  }

  //initializer
  static initPaths() async {
    var status = await Permission.storage.status;
    if (status.isUndetermined || status.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      if (!statuses[0].isGranted) {
        return;
      }
    }
    await _initRootPath();

    var paths = [downloadsPath, cachePath, portraitsPath];
    for (var path in paths) {
      if (!await Directory(path).exists()) {
        await Directory(path).create(recursive: true);
      }
    }
  }
}
