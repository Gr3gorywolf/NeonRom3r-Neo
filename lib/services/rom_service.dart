import 'dart:convert';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:device_apps/device_apps.dart';
import 'package:neonrom3r/models/emulator_intent.dart';
import 'package:neonrom3r/models/rom_library_item.dart';
import 'package:neonrom3r/repository/settings_repository.dart';
import 'package:neonrom3r/services/console_service.dart';
import 'package:neonrom3r/services/files_system_service.dart';
import 'package:neonrom3r/utils/time_helpers.dart';

class RomService {
  static List<EmulatorIntent> get _intents {
    var file = File(FileSystemService.emulatorIntentsFilePath);
    List<EmulatorIntent> intents = [];
    if (file.existsSync()) {
      for (var json in json.decode(file.readAsStringSync())) {
        intents.add(EmulatorIntent.fromJson(json));
      }
    }
    return intents;
  }

  static Future openDownloadedRom(RomLibraryItem download) async {
    var intents = _intents;
    var console = ConsoleService.getConsoleFromName(download.rom.console);
    EmulatorIntent? emulatorIntent = null;
    for (var intent in intents) {
      if (intent.consoleSlug == console!.slug) {
        emulatorIntent = intent;
        break;
      }
    }
    if (emulatorIntent != null) {
      for (var intent in emulatorIntent.intents!) {
        if (await DeviceApps.isAppInstalled(intent.package!)) {
          await _launchIntent(intent, download.filePath);
        }
      }
    }
    print(download);
  }

  static Future _launchIntent(Intents intent, String? romPath) async {
    String? action = null;
    if (intent.action != null) {
      if (intent.action!.endsWith("VIEW")) {
        action = "action_view";
      }
    }
    await AndroidIntent(
            data: romPath,
            type: intent.type,
            package: intent.package,
            componentName: intent.activity,
            action: "action_view")
        .launch();
  }

  static Future catchEmulatorsIntents() async {
    try {
      var intents = await SettingsRepository().fetchIntentsSettings();
      new File(FileSystemService.emulatorIntentsFilePath).writeAsStringSync(
          json.encode(intents.map((e) => e.toJson()).toList()));
    } catch (err) {}
  }

  static String normalizeRomTitle(String input) {
    var value = input.toLowerCase();
    value = value.replaceAll(RegExp(r'\(.*?\)'), '');
    value = value.replaceAll(RegExp(r'\[.*?\]'), '');
    value = value.replaceAll(RegExp(r'[-+_]'), ' ');
    value = value.replaceAll(RegExp(r'[^a-z0-9\s]'), '');
    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    value = value.replaceAll(" ", "");
    return value;
  }

  static String getLastPlayedLabel(RomLibraryItem? downloadedRom) {
    if (downloadedRom == null) {
      return "Not installed";
    }

    if (downloadedRom.playTimeMins > 0) {
      return "⏱ Played ${TimeHelpers.formatMinutes(downloadedRom.playTimeMins.toInt())}";
    }

    if (downloadedRom.lastPlayedAt != null) {
      return "⏱ Last played ${TimeHelpers.getTimeAgo(downloadedRom.lastPlayedAt!)}";
    }

    if (downloadedRom.downloadedAt != null) {
      return "Installed ${TimeHelpers.getTimeAgo(downloadedRom.downloadedAt!)}";
    }

    if (downloadedRom.addedAt != null) {
      return "Added ${TimeHelpers.getTimeAgo(downloadedRom.addedAt!)}";
    }

    return "Not played yet";
  }
}
