import 'dart:convert';

import 'package:yamata_launcher/models/console.dart';
import 'package:yamata_launcher/models/emulator.dart';
import 'package:http/http.dart' as http;
import 'package:yamata_launcher/services/console_service.dart';
import 'package:yamata_launcher/constants/app_constants.dart';

class EmulatorsRepository {
  Future<Map<Console, List<Emulator>>> fetchEmulators() async {
    Map<Console, List<Emulator>> emulatorsMap = {};
    var client = new http.Client();
    var res = await client
        .get(Uri.parse("${AppConstants.apiBasePath}/Data/Emulators.json"));
    if (res.statusCode == 200) {
      Map<String, dynamic> body = json.decode(res.body);
      for (var romK in body.keys) {
        List<Emulator> _emulators = [];
        for (var rom in body[romK]) {
          _emulators.add(Emulator.fromJson(rom));
        }
        var console = ConsoleService.getConsoleFromName(romK);
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
