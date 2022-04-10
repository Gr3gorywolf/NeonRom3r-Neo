import 'dart:io';
import 'package:neonrom3r/utils/files_system_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static getCacheSignature(key) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      return prefs.getString("cache-signature-" + key);
    } catch (err) {
      return null;
    }
  }

  static Future setCacheSignature(key, signature) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("cache-signature-" + key, signature);
  }

  static writeCacheFile(String fileName, String content) {
    File registryFile = File(FileSystemHelper.cachePath + "/" + fileName);
    registryFile.writeAsStringSync(content);
  }

  static retrieveCacheFile(String fileName) {
    File registryFile = File(FileSystemHelper.cachePath + "/" + fileName);
    if (!registryFile.existsSync()) {
      return null;
    }
    return registryFile.readAsStringSync();
  }
}
