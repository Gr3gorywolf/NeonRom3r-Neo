import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:neonrom3r/models/console.dart';

import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/utils/cache_helper.dart';
import 'package:neonrom3r/utils/constants.dart';
import 'package:neonrom3r/utils/files_system_helper.dart';

class RomsRepository {
  Future<List<RomInfo>> fetchRoms(Console console) async {
    List<RomInfo> roms = [];
    if (console.fromLocalSource != null && console.fromLocalSource == true) {
      File consoleFile = File(
          FileSystemHelper.consoleSourcesPath + "/" + console.slug + ".json");
      if (await consoleFile.exists()) {
        String jsonString = await consoleFile.readAsString();
        for (var rom in json.decode(jsonString)['games']) {
          roms.add(RomInfo.fromJson(rom));
        }
        return roms;
      }
    }
    var baseUrl = "${Constants.apiBasePath}/Data/Roms/${console.slug}.json";
    var client = new http.Client();
    //If is catched tries to retrieve the cache file
    var signature = await CacheHelper.getCacheSignature(console.slug);
    if (signature != null) {
      var res = await client.head(Uri.parse(baseUrl));
      if (signature == res.headers['content-length']) {
        var file = CacheHelper.retrieveCacheFile("${console.slug}.json");
        if (file != null) {
          for (var rom in json.decode(file)['games']) {
            roms.add(RomInfo.fromJson(rom));
          }
          return roms;
        }
      }
    }
    var res = await client.get(Uri.parse(baseUrl));
    var headers = res.headers;
    if (res.statusCode == 200 && res.body != null) {
      CacheHelper.writeCacheFile("${console.slug}.json", res.body);
      await CacheHelper.setCacheSignature(
          console.slug, res.headers['content-length']);
      for (var rom in json.decode(res.body)['games']) {
        roms.add(RomInfo.fromJson(rom));
      }
      return roms;
    } else {
      return [];
    }
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
