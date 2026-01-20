import 'dart:convert';
import 'dart:io';

import 'package:yamata_launcher/constants/console_constants.dart';
import 'package:yamata_launcher/models/console.dart';
import 'package:yamata_launcher/models/console_source.dart';
import 'package:yamata_launcher/services/files_system_service.dart';
import 'package:yamata_launcher/utils/string_helper.dart';

class ConsoleService {
  static List<Console> consolesFromExternalSources = [];

  static String _getSourceFilePath(Console console) {
    return FileSystemService.consoleSourcesPath +
        "/" +
        StringHelper.removeInvalidPathCharacters(
            (console.slug ?? "") + "-" + (console?.altName ?? "")) +
        ".json";
  }

  static Future deleteConsoleSource(Console console) async {
    consolesFromExternalSources
        .removeWhere((element) => element.slug == console.slug);
    File sourceFile = File(_getSourceFilePath(console));
    if (await sourceFile.exists()) {
      await sourceFile.delete();
    }
  }

  static Future<ConsoleSource?> getConsoleSource(Console console) async {
    File consoleFile = File(_getSourceFilePath(console));
    if (await consoleFile.exists()) {
      String jsonString = await consoleFile.readAsString();
      var consoleSource = ConsoleSource.fromJson(json.decode(jsonString));
      return consoleSource;
    }
    return null;
  }

  static Future<bool> addConsoleSource(ConsoleSource source) async {
    File consoleFile = File(_getSourceFilePath(source.console));
    if (consoleFile.existsSync()) {
      return false;
    }
    consolesFromExternalSources.add(source.console);
    String jsonString = json.encode(source.toJson());

    await consoleFile.writeAsString(jsonString);
    return true;
  }

  static Future<bool> updateConsoleSource(ConsoleSource source) async {
    File consoleFile = File(_getSourceFilePath(source.console));
    if (!consoleFile.existsSync()) {
      return false;
    }
    var index = consolesFromExternalSources.indexWhere((element) =>
        element.slug == source.console.slug &&
        element.altName == source.console.altName);
    consolesFromExternalSources[index] = source.console;
    String jsonString = json.encode(source.toJson());
    await consoleFile.writeAsString(jsonString);
    return true;
  }

  static Future loadConsoleSources() async {
    consolesFromExternalSources = [];
    Directory consoleSourcesDir =
        Directory(FileSystemService.consoleSourcesPath);
    if (await consoleSourcesDir.exists()) {
      var consoleFiles = consoleSourcesDir.listSync();
      for (var file in consoleFiles) {
        if (file.path.endsWith(".json")) {
          String jsonString = await File(file.path).readAsString();
          var consoleSource = ConsoleSource.fromJson(json.decode(jsonString));
          consolesFromExternalSources.add(consoleSource.console);
        }
      }
    }
  }

  static List<Console> getConsoles({unique = false}) {
    var allConsoles = [
      ...consolesFromExternalSources,
      ...ConsoleConstants.defaultConsoles
    ];
    if (!unique) {
      return allConsoles;
    }
    var uniqueConsoles = <String, Console>{};
    for (var console in allConsoles) {
      uniqueConsoles[console.slug ?? ""] = console;
    }
    return uniqueConsoles.values.toList();
  }

  static Console? getConsoleFromName(String? name) {
    var consoles = getConsoles();
    var results = consoles.where((element) =>
        element.altName == name ||
        element.name == name ||
        element.slug == name);
    if (results.isEmpty) {
      return null;
    } else {
      return results.first;
    }
  }
}
