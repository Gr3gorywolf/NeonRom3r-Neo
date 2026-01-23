import 'package:yamata_launcher/models/contracts/json_serializable.dart';

class EmulatorSetting implements JsonSerializable {
  String console = "";
  String emulatorBinary = "";
  String launchParams = "";

  EmulatorSetting(
      {required this.console,
      required this.emulatorBinary,
      this.launchParams = ""});

  EmulatorSetting.fromJson(Map<String, dynamic> json) {
    console = json['console'];
    emulatorBinary = json['emulatorBinary'];
    launchParams = json['launchParams'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['console'] = this.console;
    data['emulatorBinary'] = this.emulatorBinary;
    data['launchParams'] = this.launchParams;
    return data;
  }
}
