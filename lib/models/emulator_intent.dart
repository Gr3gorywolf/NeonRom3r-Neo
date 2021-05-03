class EmulatorIntent {
  String consoleSlug;
  bool shouldUncompress;
  List<Intents> intents;

  EmulatorIntent({this.consoleSlug, this.shouldUncompress, this.intents});

  EmulatorIntent.fromJson(Map<String, dynamic> json) {
    consoleSlug = json['console_slug'];
    shouldUncompress = json['should_uncompress'];
    if (json['intents'] != null) {
      intents = [];
      json['intents'].forEach((v) {
        intents.add(new Intents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['console_slug'] = this.consoleSlug;
    data['should_uncompress'] = this.shouldUncompress;
    if (this.intents != null) {
      data['intents'] = this.intents.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Intents {
  String package;
  String activity;
  String type;
  String action;

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
