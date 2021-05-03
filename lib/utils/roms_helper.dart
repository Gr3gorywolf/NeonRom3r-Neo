import 'dart:convert';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:device_apps/device_apps.dart';
import 'package:test_app/models/emulator_intent.dart';
import 'package:test_app/models/rom_download.dart';
import 'package:test_app/repository/settings_repository.dart';
import 'package:test_app/utils/consoles_helper.dart';
import 'package:test_app/utils/files_system_helper.dart';

class RomsHelper {
  static List<EmulatorIntent> get _intents {
    var file = File(FileSystemHelper.emulatorIntentsFile);
    List<EmulatorIntent> intents = [];
    if (file.existsSync()) {
      for (var json in json.decode(file.readAsStringSync())) {
        intents.add(EmulatorIntent.fromJson(json));
      }
    }
    return intents;
  }

  static Future openDownloadedRom(RomDownload download) async {
    var intents = _intents;
    var console = ConsolesHelper.getConsoleFromName(download.console);
    EmulatorIntent emulatorIntent = null;
    for (var intent in intents) {
      if (intent.consoleSlug == console.slug) {
        emulatorIntent = intent;
        break;
      }
    }
    if (emulatorIntent != null) {
      for (var intent in emulatorIntent.intents) {
        if (await DeviceApps.isAppInstalled(intent.package)) {
          await _launchIntent(intent, download.filePath);
        }
      }
    }
    print(download);
  }

  static Future _launchIntent(Intents intent, String romPath) async {
    String action = null;
    if (intent.action != null) {
      if (intent.action.endsWith("VIEW")) {
        action = "action_view";
      }
    }
    await AndroidIntent(
            data: romPath,
            type: intent.type,
            package: intent.package,
            componentName:  intent.activity,
            action: "action_view")
        .launch();
  }

  static Future catchEmulatorsIntents() async {
    try {
      var intents = await SettingsRepository().fetchIntentsSettings();
      new File(FileSystemHelper.emulatorIntentsFile).writeAsStringSync(
          json.encode(intents.map((e) => e.toJson()).toList()));
    } catch (err) {}
  }
}
