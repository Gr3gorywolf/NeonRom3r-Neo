import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_apps/device_apps.dart';
import 'package:file_picker/file_picker.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:yamata_launcher/database/app_database.dart';
import 'package:yamata_launcher/database/daos/emulator_settings_dao.dart';
import 'package:yamata_launcher/database/daos/library_dao.dart';
import 'package:yamata_launcher/main.dart';
import 'package:yamata_launcher/models/emulator_intent.dart';
import 'package:yamata_launcher/models/rom_library_item.dart';
import 'package:yamata_launcher/providers/library_provider.dart';
import 'package:yamata_launcher/repository/settings_repository.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/services/console_service.dart';
import 'package:yamata_launcher/services/emulator_service.dart';
import 'package:yamata_launcher/services/files_system_service.dart';
import 'package:yamata_launcher/ui/widgets/extraction_dialog.dart';
import 'package:yamata_launcher/utils/process_helper.dart';
import 'package:yamata_launcher/utils/string_helper.dart';
import 'package:yamata_launcher/utils/time_helpers.dart';
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
    EmulatorLaunchResult emulatorLaunchResult = EmulatorLaunchResult.success;
    if (db == null) {
      return;
    }
    var emulatorSetting =
        await EmulatorSettingsDao(db!).get(download.rom.console);
    if (emulatorSetting == null) {
      AlertsService.showErrorSnackbar(navigatorKey.currentContext!,
          exception: Exception(
              "No emulator configured for ${ConsoleService.getConsoleFromName(download.rom.console)?.name ?? download.rom.console}. Please set it up in settings."));
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
    String emulatorBinary = download.overrideEmulator?.isNotEmpty ?? false
        ? download.overrideEmulator ?? ""
        : emulatorSetting.emulatorBinary;
    print("Launching emulator ${emulatorBinary} with params: $launchParams");
    updateLibraryItem();
    provider.setGameRunning(download.rom.slug, true);
    if (Platform.isAndroid) {
      emulatorLaunchResult = await EmulatorService.launchEmulator(
          download.rom.console, emulatorBinary, download.filePath ?? "");
    } else {
      var process = await Process.start(emulatorBinary, launchParams);
      await process.exitCode;
    }
    if (_activeGames[download.rom.slug] != null) {
      _activeGames[download.rom.slug]?.cancel();
      _activeGames.remove(download.rom.slug);
      provider.setGameRunning(download.rom.slug, false);
      print("Stopped playtime tracking for ${download.rom.slug}");
    }

    if (Platform.isAndroid &&
        emulatorLaunchResult == EmulatorLaunchResult.needsUncompression) {
      AlertsService.showAlert(
          navigatorKey.currentContext!,
          "Rom needs uncompression",
          "The selected emulator requires the ROM to be uncompressed before launching, do you want to extract it now?",
          acceptTitle: "Yes", callback: () {
        extractRom(download);
      });
    }
  }

  static Future extractRom(RomLibraryItem downloadedRom) async {
    var resultFile = await ExtractionDialog.show(
        navigatorKey.currentContext!, File(downloadedRom.filePath ?? ""));
    if (resultFile == null) {
      AlertsService.showErrorSnackbar(navigatorKey.currentContext!,
          exception: Exception("Failed to extract ROM from zip file."));
      return;
    }
    var provider = Provider.of<LibraryProvider>(navigatorKey.currentContext!,
        listen: false);
    downloadedRom.filePath = resultFile.path;
    if (Platform.isAndroid) {
      MediaScanner.loadMedia(path: resultFile.path);
      MediaScanner.loadMedia(path: resultFile.parent.path);
    }
    provider.updateLibraryItem(downloadedRom);
    Future.microtask(() {
      AlertsService.showSnackbar(
          navigatorKey.currentContext!, "ROM extracted successfully!");
    });
  }

  static String normalizeRomTitle(String input) {
    final buffer = StringBuffer();

    final cleaned =
        input.toLowerCase().replaceAll(RegExp(r'\(.*?\)|\[.*?\]'), '');

    for (final rune in cleaned.runes) {
      final mapped = StringHelper.unicodeMap[rune];
      if (mapped != null) {
        buffer.writeCharCode(mapped);
        continue;
      }

      if ((rune >= 97 && rune <= 122) || (rune >= 48 && rune <= 57)) {
        buffer.writeCharCode(rune);
      }
    }

    return buffer.toString();
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
