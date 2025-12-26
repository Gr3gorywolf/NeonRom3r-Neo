import 'package:yamata_launcher/models/contracts/json_serializable.dart';

class EmulatorIntent implements JsonSerializable {
  String? package;
  String? activity;
  String? type;
  String? action;
  bool? shouldUncompress;

  EmulatorIntent(
      {this.package,
      this.activity,
      this.type,
      this.action,
      this.shouldUncompress = false});

  EmulatorIntent.fromJson(Map<String, dynamic> json) {
    package = json['package'];
    activity = json['activity'];
    type = json['type'];
    action = json['action'];
    shouldUncompress = json['should_uncompress'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['package'] = this.package;
    data['activity'] = this.activity;
    data['type'] = this.type;
    data['action'] = this.action;
    data['should_uncompress'] = this.shouldUncompress;
    return data;
  }
}

class Intents implements JsonSerializable {
  String? package;
  String? activity;
  String? type;
  String? action;

  Intents({this.package, this.activity, this.type, this.action});

  Intents.fromJson(Map<String, dynamic> json) {
    package = json['package'];
    activity = json['activity'];
    type = json['type'];
    action = json['action'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['package'] = this.package;
    data['activity'] = this.activity;
    data['type'] = this.type;
    data['action'] = this.action;
    return data;
  }
}
