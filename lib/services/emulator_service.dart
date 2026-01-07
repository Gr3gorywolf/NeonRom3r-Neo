import 'package:android_intent_plus/android_intent.dart';
import 'package:yamata_launcher/constants/files_constants.dart';
import 'package:yamata_launcher/main.dart';
import 'package:yamata_launcher/models/emulator_intent.dart';
import 'package:yamata_launcher/repository/emulator_intents_repository.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/services/native/intents_android_interface.dart';

enum EmulatorLaunchResult { success, failedToLaunch, needsUncompression }

class EmulatorService {
  static _parseIntentAction(String action) {
    switch (action) {
      case 'VIEW':
      case 'android.intent.action.VIEW':
        return 'action_view';
      case 'MAIN':
      case 'android.intent.action.MAIN':
        return 'action_main';
      default:
        return action;
    }
  }

  static Future<EmulatorLaunchResult> launchEmulator(
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
      print(matchedIntent.toJson());
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
      final intent = AndroidIntent(
          action: _parseIntentAction(
              matchedIntent.action ?? 'android.intent.action.VIEW'),
          package: matchedIntent.package,
          componentName: componentName,
          data: matchedIntent.data,
          arguments: matchedIntent.extras,
          category: matchedIntent.category,
          type: matchedIntent.type,
          flags: [
            1,
            2,
          ]);

      await intent.launch();
    } catch (e) {
      print("Error launching emulator: $e");
      AlertsService.showErrorSnackbar(navigatorKey.currentContext!,
          exception: Exception('Failed to launch emulator: ${e}'));
      return EmulatorLaunchResult.failedToLaunch;
    }
    return EmulatorLaunchResult.success;
  }
}
