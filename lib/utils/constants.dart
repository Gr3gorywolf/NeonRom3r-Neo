import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider_ex/path_provider_ex.dart';

class Constants {
  static String apiBasePath =
      "https://raw.githubusercontent.com/Gr3gorywolf/NeonRom3r-RomsInfos/master/";
  static getRootPath() async {
    var rootPath = "";
    try {
      var storageInfo = await PathProviderEx.getStorageInfo();
      if (storageInfo.length > 0) {
        rootPath = storageInfo[0].rootDir;
      }
    } on PlatformException {}
    return rootPath;
  }

  static getCachePath() async {
    return await getRootPath() + "/.romercache";
  }

  static getDownloadsPath() async {
    return await getRootPath() + "/downloaded-roms";
  }

  static getPortraitsPath() async {
    return await getCachePath() + "/portraits";
  }

  static getDownloadRegistryFile() async {
    return await getCachePath() + "/downloads.json";
  }
}
