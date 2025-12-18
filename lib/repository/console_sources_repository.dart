import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:neonrom3r/models/console_source.dart';
import 'package:neonrom3r/models/download_source.dart';
import 'package:neonrom3r/models/download_source_rom.dart';
import 'package:neonrom3r/utils/files_system_helper.dart';

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
