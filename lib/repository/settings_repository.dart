import 'dart:convert';

import 'package:test_app/models/emulator_intent.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/utils/constants.dart';

class SettingsRepository {
  Future<List<EmulatorIntent>> fetchIntentsSettings() async {
    List<EmulatorIntent> emulatorsIntents = [];
    var client = new http.Client();
    var res = await client
        .get("${Constants.apiBasePath}/Configs/EmulatorIntents.json");
    if (res.statusCode == 200) {
      for (var rom in json.decode(res.body)) {
        emulatorsIntents.add(EmulatorIntent.fromJson(rom));
      }
      return emulatorsIntents;
    } else {
      return [];
    }
  }
}
