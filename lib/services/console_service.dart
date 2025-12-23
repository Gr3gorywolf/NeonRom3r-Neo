import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yamata_launcher/constants/console_constants.dart';
import 'package:yamata_launcher/models/console.dart';
import 'package:yamata_launcher/models/console_source.dart';
import 'package:yamata_launcher/models/emulator.dart';
import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/services/files_system_service.dart';

class ConsoleService {
  static List<Console> consolesFromSources = [];

  static Future deleteConsoleSource(Console console) async {
    consolesFromSources.removeWhere((element) => element.slug == console.slug);
    File sourceFile = File(
        FileSystemService.consoleSourcesPath + "/" + console.slug + ".json");
    if (await sourceFile.exists()) {
      await sourceFile.delete();
    }
  }

  static Future<bool> addConsoleSource(ConsoleSource source) async {
    File consoleFile = File(FileSystemService.consoleSourcesPath +
        "/" +
        source.console.slug +
        ".json");
    if (consoleFile.existsSync()) {
      return false;
    }
    consolesFromSources.add(source.console);
    String jsonString = json.encode(source.toJson());

    await consoleFile.writeAsString(jsonString);
    return true;
  }

  static Future loadConsoleSources() async {
    consolesFromSources = [];
    Directory consoleSourcesDir =
        Directory(FileSystemService.consoleSourcesPath);
    if (await consoleSourcesDir.exists()) {
      var consoleFiles = consoleSourcesDir.listSync();
      for (var file in consoleFiles) {
        if (file.path.endsWith(".json")) {
          String jsonString = await File(file.path).readAsString();
          var consoleSource = ConsoleSource.fromJson(json.decode(jsonString));
          consolesFromSources.add(consoleSource.console);
        }
      }
    }
  }

  static List<Console> getConsoles() {
    return [...consolesFromSources, ...ConsoleConstants.defaultConsoles];
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
