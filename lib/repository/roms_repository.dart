import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:neonrom3r/models/console.dart';

import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/utils/cache_helper.dart';
import 'package:neonrom3r/utils/constants.dart';

class RomsRepository {
  Future<List<RomInfo>> fetchRoms(Console console) async {
    List<RomInfo> roms = [];
    var baseUrl = "${Constants.apiBasePath}/Data/${console.slug}.json";
    var client = new http.Client();
    //If is catched tries to retrieve the cache file
    var signature = await CacheHelper.getCacheSignature(console.slug);
    if (signature != null) {
      var res = await client.head(baseUrl);
      if (signature == res.headers['content-length']) {
        var file = CacheHelper.retrieveCacheFile("${console.slug}.json");
        for (var rom in json.decode(file)) {
          roms.add(RomInfo.fromJson(rom));
        }
        return roms;
      }
    }
    var res = await client.get(baseUrl);
    var headers = res.headers;
    if (res.statusCode == 200) {
      CacheHelper.writeCacheFile("${console.slug}.json", res.body);
      await CacheHelper.setCacheSignature(
          console.slug, res.headers['content-length']);
      for (var rom in json.decode(res.body)) {
        roms.add(RomInfo.fromJson(rom));
      }
      return roms;
    } else {
      return [];
    }
  }

  Future<RomInfo> fetchRomDetails(String infoLink) async {
    var client = new http.Client();
    var res = await client.get(infoLink);
    if (res.statusCode == 200) {
      return RomInfo.fromJson(json.decode(res.body));
    } else {
      return null;
    }
  }
}
