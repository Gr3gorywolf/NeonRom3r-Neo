import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:device_apps/device_apps.dart';
import 'package:neonrom3r/database/app_database.dart';
import 'package:neonrom3r/database/daos/emulator_settings_dao.dart';
import 'package:neonrom3r/database/daos/library_dao.dart';
import 'package:neonrom3r/main.dart';
import 'package:neonrom3r/models/emulator_intent.dart';
import 'package:neonrom3r/models/rom_library_item.dart';
import 'package:neonrom3r/providers/library_provider.dart';
import 'package:neonrom3r/repository/settings_repository.dart';
import 'package:neonrom3r/services/alerts_service.dart';
import 'package:neonrom3r/services/console_service.dart';
import 'package:neonrom3r/services/files_system_service.dart';
import 'package:neonrom3r/utils/process_helper.dart';
import 'package:neonrom3r/utils/time_helpers.dart';
import 'package:provider/provider.dart';

class RomService {
  static Map<String, Timer> _activeGames = {};
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
    if (db == null) {
      return;
    }
    var emulatorSetting =
        await EmulatorSettingsDao(db!).get(download.rom.console);
    if (emulatorSetting == null) {
      AlertsService.showErrorSnackbar(navigatorKey.currentContext!,
          exception: Exception(
              "No emulator configured for ${download.rom.console}. Please set it up in settings."));
      return;
    }
    var provider = Provider.of<LibraryProvider>(navigatorKey.currentContext!,
        listen: false);

    updateLibraryItem({bool addTime = false}) {
      var currentLibraryItem = provider.getLibraryItem(download.rom.slug);
      if (currentLibraryItem != null) {
        if (addTime) {
          currentLibraryItem.playTimeMins += 1;
        }
        currentLibraryItem.lastPlayedAt = DateTime.now();
        provider.updateLibraryItem(currentLibraryItem);
      }
    }

    var stopWatch = Timer.periodic(Duration(minutes: 1), (timer) async {
      updateLibraryItem(addTime: true);
    });
    _activeGames[download.rom.slug] = stopWatch;
    var openParams = download.openParams ?? "";
    List<String> launchParams = [
      ...(openParams.isEmpty ? [] : [openParams]),
      download.filePath ?? ""
    ];
    print(
        "Launching emulator ${emulatorSetting.emulatorBinary} with params: $launchParams");
    updateLibraryItem();
    provider.setGameRunning(download.rom.slug, true);
    var process =
        await Process.start(emulatorSetting.emulatorBinary, launchParams);
    await process.exitCode;
    if (_activeGames[download.rom.slug] != null) {
      _activeGames[download.rom.slug]?.cancel();
      _activeGames.remove(download.rom.slug);
      provider.setGameRunning(download.rom.slug, false);
      print("Stopped playtime tracking for ${download.rom.slug}");
    }
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
