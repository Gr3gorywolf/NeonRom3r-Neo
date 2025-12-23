import 'package:yamata_launcher/models/contracts/json_serializable.dart';

class EmulatorSetting implements JsonSerializable {
  String console = "";
  String emulatorBinary = "";

  EmulatorSetting({required this.console, required this.emulatorBinary});

  EmulatorSetting.fromJson(Map<String, dynamic> json) {
    console = json['console'];
    emulatorBinary = json['emulatorBinary'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['console'] = this.console;
    data['emulatorBinary'] = this.emulatorBinary;
    return data;
  }
}
