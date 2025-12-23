import 'dart:convert';

import 'package:yamata_launcher/models/emulator_intent.dart';
import 'package:http/http.dart' as http;
import 'package:yamata_launcher/constants/app_constants.dart';

class SettingsRepository {
  Future<List<EmulatorIntent>> fetchIntentsSettings() async {
    List<EmulatorIntent> emulatorsIntents = [];
    var client = new http.Client();
    var res = await client.get(
        Uri.parse("${AppConstants.apiBasePath}/Configs/EmulatorIntents.json"));
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
