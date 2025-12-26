import 'dart:convert';

import 'package:yamata_launcher/constants/app_constants.dart';
import 'package:yamata_launcher/models/emulator_intent.dart';
import 'package:yamata_launcher/services/cache_service.dart';
import 'package:yamata_launcher/utils/cached_fetch.dart';
import 'package:http/http.dart' as http;

class EmulatorIntentsRepository {
  Future<List<EmulatorIntent>?> fetchEmulatorIntents() async {
    List<EmulatorIntent> emulatorsIntents = [];
    var cacheKey = "emulator-intents";
    var baseUrl = "${AppConstants.apiBasePath}/Configs/EmulatorIntents.json";
    var client = new http.Client();

    var signature = await CacheService.getCacheSignature(cacheKey);
    if (signature != null) {
      var res = await client.head(Uri.parse(baseUrl));
      if (res.statusCode != 200 || signature == res.headers['content-length']) {
        var file = await CacheService.retrieveCacheFile("$cacheKey.json");
        if (file != null) {
          for (var rom in json.decode(file)) {
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
      for (var rom in json.decode(res.body)) {
        emulatorsIntents.add(EmulatorIntent.fromJson(rom));
      }
    }
    return emulatorsIntents;
  }
}
