import 'package:neonrom3r/models/rom_info.dart';

import 'console.dart';

class ConsoleSource {
  Console console = Console();
  List<RomInfo> games = [];

  ConsoleSource({required this.console, required this.games});

  ConsoleSource.fromJson(Map<String, dynamic> json) {
    var consoleData = json['console'];
    console = Console(
        fromLocalSource: true,
        name: consoleData['name'],
        slug: consoleData['slug'],
        altName: consoleData['name'],
        logoUrl: consoleData['logoUrl'],
        description: consoleData['description']);
    games = json['games'] != null
        ? (json['games'] as List).map((i) => RomInfo.fromJson(i)).toList()
        : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['console'] = {
      "name": this.console.name,
      "slug": this.console.slug,
      "logoUrl": this.console.logoUrl,
      "description": this.console.description,
    };
    data['games'] = this.games.map((v) => v.toJson()).toList();
    return data;
  }
}
