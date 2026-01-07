import 'dart:convert';

import 'package:yamata_launcher/constants/app_constants.dart';
import 'package:yamata_launcher/models/emulator_intent.dart';
import 'package:yamata_launcher/services/cache_service.dart';
import 'package:yamata_launcher/services/native/intents_android_interface.dart';
import 'package:yamata_launcher/utils/cached_fetch.dart';
import 'package:http/http.dart' as http;

class EmulatorIntentsRepository {
  parseJsonFile(String jsonString, String path, String uri) {
    jsonString = jsonString.replaceAll("{file.uri}", uri);
    jsonString = jsonString.replaceAll("{file.path}", path);
    return jsonDecode(jsonString);
  }

  Future<List<EmulatorIntent>?> fetchEmulatorIntents(
      String console, String path) async {
    List<EmulatorIntent> emulatorsIntents = [];
    var uri = await IntentsAndroidInterface.getIntentUri(path) ?? path;
    var cacheKey = "emulator-intents";
    var baseUrl = "${AppConstants.apiBasePath}/Configs/EmulatorIntents.json";
    var client = new http.Client();

    var signature = await CacheService.getCacheSignature(cacheKey);
    if (signature != null) {
      var res = await client.head(Uri.parse(baseUrl));
      if (res.statusCode != 200 || signature == res.headers['content-length']) {
        var file = await CacheService.retrieveCacheFile("$cacheKey.json");
        if (file != null) {
          print(file);
          var consoleIntents = parseJsonFile(file, path, uri)[console] ?? [];
          for (var rom in consoleIntents) {
            emulatorsIntents.add(EmulatorIntent.fromJson(rom));
          }
        }
        return emulatorsIntents;
      }
    }

    var res = await client.get(Uri.parse(baseUrl));
    if (res.statusCode == 200 && res.body != null) {
      await CacheService.writeCacheFile("$cacheKey.json", res.body);
      await CacheService.setCacheSignature(
          cacheKey, res.headers['content-length'] ?? "");
      var consoleIntents = parseJsonFile(res.body, path, uri)[console] ?? [];
      for (var rom in consoleIntents) {
        emulatorsIntents.add(EmulatorIntent.fromJson(rom));
      }
    }
    return emulatorsIntents;
  }
}
