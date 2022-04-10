import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/models/emulator.dart';
import 'package:neonrom3r/models/rom_info.dart';

class ConsolesHelper {
  static List<Console> getConsoles() {
    return [
      Console(name: "Gameboy", altName: "GameBoy", slug: "GB"),
      Console(name: "Gameboy Color", altName: "GameBoyColor", slug: "GBC"),
      Console(name: "Gameboy Advance", altName: "GameBoyAdvance", slug: "GBA"),
      Console(name: "Nintendo", altName: "Nintendo", slug: "NES"),
      Console(name: "Super Nintendo", altName: "SuperNintendo", slug: "SNES"),
      Console(name: "Nintendo 64", altName: "Nintendo64", slug: "N64"),
      Console(name: "Playstation", altName: "Playstation", slug: "PSX"),
      Console(name: "Sega Genesis", altName: "Sega_Genesis", slug: "Genesis"),
      Console(name: "Dreamcast", altName: "Sega_Dreamcast", slug: "Dreamcast"),
      Console(name: "Nintendo DS", altName: "Nintendo_DS", slug: "NDS"),
      Console(
          name: "Nintendo Gamecube",
          altName: "NintendoGamecube",
          slug: "Gamecube"),
      Console(name: "Psp", altName: "Psp", slug: "PSP")
    ];
  }

  static Console getConsoleFromName(String name) {
    var consoles = getConsoles();
    var results = consoles.where((element) =>
        element.altName == name ||
        element.name == name ||
        element.slug == name);
    if (results.isEmpty) {
      return null;
    } else {
      return results.first;
    }
  }
}
