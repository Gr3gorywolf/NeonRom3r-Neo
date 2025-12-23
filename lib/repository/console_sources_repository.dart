import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yamata_launcher/models/console_source.dart';
import 'package:yamata_launcher/models/download_source.dart';
import 'package:yamata_launcher/models/download_source_rom.dart';
import 'package:yamata_launcher/services/files_system_service.dart';

class ConsoleSourcesRepository {
  Future<ConsoleSource?> fetchSource(String sourceUrl) async {
    var client = new http.Client();
    var res = await client.get(Uri.parse(sourceUrl));
    if (res.statusCode == 200) {
      var responseData = json.decode(res.body);
      return ConsoleSource.fromJson(responseData);
    } else {
      return null;
    }
  }
}
