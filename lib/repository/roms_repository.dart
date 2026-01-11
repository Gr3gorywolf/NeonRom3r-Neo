import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:yamata_launcher/models/console.dart';
import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/constants/app_constants.dart';
import 'package:yamata_launcher/services/console_service.dart';
import 'package:yamata_launcher/utils/cached_fetch.dart';

class RomsRepository {
  Future<List<RomInfo>> fetchRoms(Console console) async {
    Map<String, RomInfo> roms = {};
    final url = "${AppConstants.apiBasePath}/Data/Roms/${console.slug}.json";
    var externalConsoles = ConsoleService.consolesFromExternalSources;
    var foundExternalSources =
        externalConsoles.where((c) => c.slug == console.slug).toList();
    final result =
        await CachedFetch.withContentLengthSignature<Map<String, RomInfo>>(
      key: console.slug ?? "unknown_console",
      url: url,
      parser: (json) {
        final Map<String, RomInfo> roms = {};
        for (final rom in json['games']) {
          roms[rom['slug'] ?? ""] = RomInfo.fromJson(rom);
        }
        return roms;
      },
    );

    if (result != null) roms.addAll(result);
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
