import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:yamata_launcher/models/console.dart';
import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/services/cache_service.dart';
import 'package:yamata_launcher/constants/app_constants.dart';
import 'package:yamata_launcher/services/console_service.dart';
import 'package:yamata_launcher/services/files_system_service.dart';

class RomsRepository {
  Future<List<RomInfo>> fetchRoms(Console console) async {
    Map<String, RomInfo> roms = {};
    var externalConsoles = ConsoleService.consolesFromExternalSources;
    var foundExternalSources =
        externalConsoles.where((c) => c.slug == console.slug).toList();
    var baseUrl = "${AppConstants.apiBasePath}/Data/Roms/${console.slug}.json";
    var client = new http.Client();
    var retrievedFromCache = false;
    //If is catched tries to retrieve the cache file
    var signature = await CacheService.getCacheSignature(console?.slug ?? "");
    if (signature != null) {
      var res = await client.head(Uri.parse(baseUrl));
      if (signature == res.headers['content-length']) {
        var file = await CacheService.retrieveCacheFile("${console.slug}.json");
        if (file != null) {
          for (var rom in json.decode(file)['games']) {
            roms[rom['slug'] ?? ""] = RomInfo.fromJson(rom);
          }
        }
        retrievedFromCache = true;
      }
    }

    //If its not cached retrieve it from the web
    if (!retrievedFromCache) {
      var res = await client.get(Uri.parse(baseUrl));
      if (res.statusCode == 200 && res.body != null) {
        await CacheService.writeCacheFile("${console.slug}.json", res.body);
        await CacheService.setCacheSignature(
            console.slug ?? "", res.headers['content-length'] ?? "");
        for (var rom in json.decode(res.body)['games']) {
          roms[rom['slug'] ?? ""] = RomInfo.fromJson(rom);
        }
      }
    }
    // Load external sources and override local roms if necessary
    if (foundExternalSources.isNotEmpty) {
      for (var console in foundExternalSources) {
        var consoleSource = await ConsoleService.getConsoleSource(console);
        if (consoleSource == null) continue;
        for (var rom in consoleSource.games) {
          roms[rom.slug ?? ""] = rom;
        }
      }
    }

    return roms.values.toList();
  }

  Future<RomInfo?> fetchRomDetails(String infoLink) async {
    var client = new http.Client();
    var res = await client.get(Uri.parse(infoLink));
    if (res.statusCode == 200) {
      return RomInfo.fromJson(json.decode(res.body));
    } else {
      return null;
    }
  }
}
