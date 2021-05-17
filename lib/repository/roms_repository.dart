import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:neonrom3r/models/console.dart';

import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/utils/constants.dart';

class RomsRepository {
  Future<List<RomInfo>> fetchRoms(Console console) async {
    List<RomInfo> roms = [];
    var client = new http.Client();
    var res =
        await client.get("${Constants.apiBasePath}/Data/${console.slug}.json");
    if (res.statusCode == 200) {
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
