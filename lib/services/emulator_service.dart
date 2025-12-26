import 'package:android_intent_plus/android_intent.dart';
import 'package:yamata_launcher/main.dart';
import 'package:yamata_launcher/models/emulator_intent.dart';
import 'package:yamata_launcher/repository/emulator_intents_repository.dart';
import 'package:yamata_launcher/services/alerts_service.dart';

class EmulatorService {
  static Future<void> launchEmulator(
      String packageName, String filePath) async {
    try {
      print(
          'Launching emulator with package: $packageName and file: $filePath');
      var intents = await EmulatorIntentsRepository().fetchEmulatorIntents();
      if (intents == null) {
        intents = [];
      }
      var matchedIntent = intents.firstWhere(
          (intent) => intent.package == packageName,
          orElse: () => EmulatorIntent(
              package: packageName, action: 'action_view', type: '*/*'));
      print(
          'Matched intent: ${matchedIntent.action}, ${filePath}, ${matchedIntent.type}, ${matchedIntent.activity}, ${matchedIntent.package}');
      final intent = AndroidIntent(
        action: matchedIntent.action ?? 'action_view',
        package: packageName,
        componentName:
            matchedIntent.activity != null ? matchedIntent.activity : null,
        data: "$filePath",
        type: matchedIntent.type,
      );

      await intent.launch();
    } catch (e) {
      print("Error launching emulator: $e");
      AlertsService.showErrorSnackbar(navigatorKey.currentContext!,
          exception: Exception('Failed to launch emulator: ${e}'));
      return;
    }
  }
}
