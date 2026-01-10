import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:provider/provider.dart';
import 'package:yamata_launcher/app_router.dart';
import 'package:yamata_launcher/constants/files_constants.dart';
import 'package:yamata_launcher/database/app_database.dart';
import 'package:yamata_launcher/database/daos/emulator_settings_dao.dart';
import 'package:yamata_launcher/models/emulator_intent.dart';
import 'package:yamata_launcher/models/rom_library_item.dart';
import 'package:yamata_launcher/providers/library_provider.dart';
import 'package:yamata_launcher/repository/emulator_intents_repository.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/services/console_service.dart';
import 'package:yamata_launcher/services/native/intents_android_interface.dart';
import 'package:android_intent_plus/flag.dart' as flag;
import 'package:yamata_launcher/services/rom_service.dart';

enum EmulatorLaunchResult { success, failedToLaunch, needsUncompression }

class EmulatorService {
  static Map<String, Timer> _activeGames = {};

  static Future openRom(RomLibraryItem download) async {
    EmulatorLaunchResult emulatorLaunchResult = EmulatorLaunchResult.success;
    if (db == null) {
      return;
    }
    var emulatorSetting =
        await EmulatorSettingsDao(db!).get(download.rom.console);
    if (emulatorSetting == null) {
      AlertsService.showErrorSnackbar(
          "No emulator configured for ${ConsoleService.getConsoleFromName(download.rom.console)?.name ?? download.rom.console}. Please set it up in settings.");
      return;
    }
    var provider =
        Provider.of<LibraryProvider>(navigatorContext!, listen: false);

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
    try {
      if (Platform.isAndroid) {
        emulatorLaunchResult = await EmulatorService.launchEmulatorIntent(
            download.rom.console, emulatorBinary, download.filePath ?? "");
      } else {
        Process process;
        if (Platform.isMacOS) {
          process = await Process.start(
              "open", ["-a", emulatorBinary, ...launchParams]);
        } else {
          process = await Process.start(emulatorBinary, launchParams);
        }
        await process.exitCode;
      }
    } on Exception catch (err) {
      AlertsService.showErrorSnackbar("Failed to open the rom", exception: err);
    }

    if (_activeGames[download.rom.slug] != null) {
      _activeGames[download.rom.slug]?.cancel();
      _activeGames.remove(download.rom.slug);
      provider.setGameRunning(download.rom.slug, false);
      print("Stopped playtime tracking for ${download.rom.slug}");
    }

    if (Platform.isAndroid &&
        emulatorLaunchResult == EmulatorLaunchResult.needsUncompression) {
      AlertsService.showAlert(navigatorContext!, "Rom needs to be extracted",
          "The selected emulator requires the ROM to be extracted before launching, do you want to extract it now?",
          acceptTitle: "Yes", callback: () {
        RomService.extractRom(download);
      });
    }
  }

  /**
   * Launches an emulator intent on Android devices.
   */
  static Future<EmulatorLaunchResult> launchEmulatorIntent(
      String console, String packageName, String filePath) async {
    try {
      print(
          'Launching emulator with package: $packageName and file: $filePath');
      var intents = await EmulatorIntentsRepository()
          .fetchEmulatorIntents(console, filePath);
      if (intents == null) {
        intents = [];
      }
      var matchedIntent = intents.firstWhere(
          (intent) => intent.package == packageName,
          orElse: () => EmulatorIntent(
              package: packageName, action: 'android.intent.action.VIEW'));
      var isCompressed = VALID_COMPRESSED_EXTENSIONS
          .any((ext) => filePath.toLowerCase().endsWith(ext));
      if (matchedIntent.requireExtraction == true && isCompressed) {
        return EmulatorLaunchResult.needsUncompression;
      }

      var componentName = matchedIntent.activity != null
          ? matchedIntent.activity
              ?.replaceFirst(matchedIntent.package! + "/", '')
          : null;
      print(
          'Using component name: $componentName and extras: ${matchedIntent.extras}');
      await IntentsAndroidInterface.grantUriPermission(
          await IntentsAndroidInterface.getIntentUri(filePath) ?? filePath,
          packageName);
      final intent = AndroidIntent(
          action: matchedIntent.action,
          package: matchedIntent.package,
          componentName: componentName,
          data: matchedIntent.data,
          arguments: matchedIntent.extras,
          category: matchedIntent.category,
          type: matchedIntent.type ?? "*/*",
          flags: [
            flag.Flag.FLAG_ACTIVITY_NEW_TASK,
            flag.Flag.FLAG_GRANT_READ_URI_PERMISSION,
            flag.Flag.FLAG_GRANT_WRITE_URI_PERMISSION,
            flag.Flag.FLAG_ACTIVITY_CLEAR_TASK
          ]);

      await intent.launch();
    } on Exception catch (e) {
      print("Error launching emulator: $e");
      AlertsService.showErrorSnackbar('Failed to launch emulator',
          exception: e);
      return EmulatorLaunchResult.failedToLaunch;
    }
    return EmulatorLaunchResult.success;
  }
}
