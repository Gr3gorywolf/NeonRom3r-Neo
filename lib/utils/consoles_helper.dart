import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/models/console_source.dart';
import 'package:neonrom3r/models/emulator.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/utils/files_system_helper.dart';

class ConsolesHelper {
  static List<Console> consolesFromSources = [];

  static Future deleteConsoleSource(Console console) async {
    consolesFromSources.removeWhere((element) => element.slug == console.slug);
    File sourceFile =
        FileSystemHelper.consoleSourcesPath + "/" + console.slug + ".json";
    if (await sourceFile.exists()) {
      await sourceFile.delete();
    }
  }

  static Future addConsoleSource(ConsoleSource source) async {
    consolesFromSources.add(source.console);
    String jsonString = json.encode(source.toJson());
    File consoleFile = File(FileSystemHelper.consoleSourcesPath +
        "/" +
        source.console.slug +
        ".json");
    await consoleFile.writeAsString(jsonString);
  }

  static Future loadConsoleSources() async {
    consolesFromSources = [];
    Directory consoleSourcesDir =
        Directory(FileSystemHelper.consoleSourcesPath);
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
    return [
      ...consolesFromSources,
      // =========================
      // Nintendo
      // =========================
      Console(name: "Game Boy", altName: "Nintendo - Game Boy", slug: "gb"),
      Console(
          name: "Game Boy Color",
          altName: "Nintendo - Game Boy Color",
          slug: "gbc"),
      Console(
          name: "Game Boy Advance",
          altName: "Nintendo - Game Boy Advance",
          slug: "gba"),
      Console(
          name: "Nintendo Entertainment System",
          altName: "Nintendo - Nintendo Entertainment System",
          slug: "nes"),
      Console(
          name: "Super Nintendo Entertainment System",
          altName: "Nintendo - Super Nintendo Entertainment System",
          slug: "snes"),
      Console(
          name: "Nintendo 64", altName: "Nintendo - Nintendo 64", slug: "n64"),
      Console(name: "GameCube", altName: "Nintendo - GameCube", slug: "gc"),
      Console(name: "Wii", altName: "Nintendo - Wii", slug: "wii"),
      Console(
          name: "Nintendo DS", altName: "Nintendo - Nintendo DS", slug: "nds"),
      Console(
          name: "Nintendo 3DS",
          altName: "Nintendo - Nintendo 3DS",
          slug: "3ds"),
      Console(
          name: "Virtual Boy", altName: "Nintendo - Virtual Boy", slug: "vb"),

      // =========================
      // Sony
      // =========================
      Console(name: "PlayStation", altName: "Sony - PlayStation", slug: "ps1"),
      Console(
          name: "PlayStation 2", altName: "Sony - PlayStation 2", slug: "ps2"),
      Console(
          name: "PlayStation 3", altName: "Sony - PlayStation 3", slug: "ps3"),
      Console(
          name: "PlayStation Portable",
          altName: "Sony - PlayStation Portable",
          slug: "psp"),
      Console(
          name: "PlayStation Vita",
          altName: "Sony - PlayStation Vita",
          slug: "psvita"),
      // =========================
      // Sega
      // =========================
      Console(
          name: "Mega Drive / Genesis",
          altName: "Sega - Mega Drive - Genesis",
          slug: "genesis"),
      Console(name: "Sega 32X", altName: "Sega - 32X", slug: "sega32x"),
      Console(name: "Sega Saturn", altName: "Sega - Saturn", slug: "saturn"),
      Console(
          name: "Dreamcast", altName: "Sega - Dreamcast", slug: "dreamcast"),
      Console(name: "Game Gear", altName: "Sega - Game Gear", slug: "gamegear"),

      // =========================
      // SNK
      // =========================
      Console(name: "Neo Geo", altName: "SNK - Neo Geo", slug: "neogeo"),
      Console(
          name: "Neo Geo Pocket", altName: "SNK - Neo Geo Pocket", slug: "ngp"),
      Console(
          name: "Neo Geo Pocket Color",
          altName: "SNK - Neo Geo Pocket Color",
          slug: "ngpc"),
      // =========================
      // Commodore
      // =========================
      Console(name: "Commodore 64", altName: "Commodore - 64", slug: "c64"),
      Console(
          name: "Commodore Amiga", altName: "Commodore - Amiga", slug: "amiga"),

      // =========================
      // Others
      // =========================
      Console(
          name: "WonderSwan",
          altName: "Bandai - WonderSwan",
          slug: "wonderswan"),
      Console(
          name: "WonderSwan Color",
          altName: "Bandai - WonderSwan Color",
          slug: "wonderswancolor"),
      Console(name: "Vectrex", altName: "GCE - Vectrex", slug: "vectrex"),
    ];
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
