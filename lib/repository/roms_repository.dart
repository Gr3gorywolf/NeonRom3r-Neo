import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test_app/models/console.dart';

import 'package:test_app/models/rom_info.dart';
import 'package:test_app/models/rom_item.dart';
import 'package:test_app/utils/constants.dart';

class RomsRepository {
  Future<List<RomItem>> fetchRoms(Console console) async {
    List<RomItem> roms = [];
    var client = new http.Client();
    var res =
        await client.get("${Constants.apiBasePath}/Data/${console.slug}.json");
    if (res.statusCode == 200) {
      for (var rom in json.decode(res.body)) {
        roms.add(RomItem.fromJson(rom));
      }
      return roms;
    } else {
      return [];
    }
  }

  Future<RomInfo> fetchRomDetails(String infoLink) async {
    List<RomInfo> roms = [];
    var client = new http.Client();
    var res = await client.get(infoLink);
    if (res.statusCode == 200) {
      return RomInfo.fromJson(json.decode(res.body));
    } else {
      return null;
    }
  }
}
