import 'package:android_intent_plus/android_intent.dart';
import 'package:yamata_launcher/constants/files_constants.dart';
import 'package:yamata_launcher/main.dart';
import 'package:yamata_launcher/models/emulator_intent.dart';
import 'package:yamata_launcher/repository/emulator_intents_repository.dart';
import 'package:yamata_launcher/services/alerts_service.dart';
import 'package:yamata_launcher/services/native/intents_android_interface.dart';

enum EmulatorLaunchResult { success, failedToLaunch, needsUncompression }

class EmulatorService {
  static Future<EmulatorLaunchResult> launchEmulator(
      String packageName, String filePath) async {
    try {
      print(
          'Launching emulator with package: $packageName and file: $filePath');
      var intents = await EmulatorIntentsRepository().fetchEmulatorIntents();
      if (intents == null) {
        intents = [];
      }
      var filePathUri =
          await IntentsAndroidInterface.getIntentUri(filePath) ?? filePath;
      var matchedIntent = intents.firstWhere(
          (intent) => intent.package == packageName,
          orElse: () => EmulatorIntent(
              package: packageName, action: 'action_view', type: '*/*'));
      print(matchedIntent.toJson());
      if (matchedIntent.shouldUncompress == true &&
          VALID_COMPRESSED_EXTENSIONS
              .any((ext) => filePath.toLowerCase().endsWith(ext))) {
        return EmulatorLaunchResult.needsUncompression;
      }
      final intent = AndroidIntent(
          action: matchedIntent.action ?? 'action_view',
          package: packageName,
          componentName:
              matchedIntent.activity != null ? matchedIntent.activity : null,
          data: filePathUri,
          type: matchedIntent.type,
          flags: [
            1, // FLAG_GRANT_READ_URI_PERMISSION
            2, // FLAG_GRANT_WRITE_URI_PERMISSION
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
