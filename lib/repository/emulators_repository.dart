import 'dart:convert';

import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/models/emulator.dart';
import 'package:http/http.dart' as http;
import 'package:neonrom3r/utils/consoles_helper.dart';
import 'package:neonrom3r/utils/constants.dart';

class EmulatorsRepository {
  Future<Map<Console, List<Emulator>>> fetchEmulators() async {
    Map<Console, List<Emulator>> emulatorsMap = {};
    var client = new http.Client();
    var res = await client.get("${Constants.apiBasePath}/Data/Emulators.json");
    if (res.statusCode == 200) {
      Map<String, dynamic> body = json.decode(res.body);
      for (var romK in body.keys) {
        List<Emulator> _emulators = [];
        for (var rom in body[romK]) {
          _emulators.add(Emulator.fromJson(rom));
        }
        var console = ConsolesHelper.getConsoleFromName(romK);
        if (console != null) {
          emulatorsMap[console] = _emulators;
        }
      }
      return emulatorsMap;
    } else {
      return {};
    }
  }
}
