import 'package:neonrom3r/models/console.dart';
import 'package:neonrom3r/models/emulator.dart';
import 'package:neonrom3r/models/rom_info.dart';

class ConsolesHelper {
  static List<Console> getConsoles() {
    return [
      // =========================
      // Nintendo
      // =========================
      Console(name: "Game Boy", altName: "Nintendo - Game Boy", slug: "gb"),
      Console(
          name: "Game Boy Color",
          altName: "Nintendo - Game Boy Color",
          slug: "gbc"),
      Console(
          name: "Game Boy Advance",
          altName: "Nintendo - Game Boy Advance",
          slug: "gba"),
      Console(
          name: "Nintendo Entertainment System",
          altName: "Nintendo - Nintendo Entertainment System",
          slug: "nes"),
      Console(
          name: "Super Nintendo Entertainment System",
          altName: "Nintendo - Super Nintendo Entertainment System",
          slug: "snes"),
      Console(
          name: "Nintendo 64", altName: "Nintendo - Nintendo 64", slug: "n64"),
      Console(name: "GameCube", altName: "Nintendo - GameCube", slug: "gc"),
      Console(name: "Wii", altName: "Nintendo - Wii", slug: "wii"),
      Console(name: "Wii U", altName: "Nintendo - Wii U", slug: "wiiu"),
      Console(
          name: "Nintendo DS", altName: "Nintendo - Nintendo DS", slug: "nds"),
      Console(
          name: "Nintendo 3DS",
          altName: "Nintendo - Nintendo 3DS",
          slug: "n3ds"),
      Console(
          name: "Virtual Boy", altName: "Nintendo - Virtual Boy", slug: "vb"),

      // =========================
      // Sony
      // =========================
      Console(name: "PlayStation", altName: "Sony - PlayStation", slug: "ps1"),
      Console(
          name: "PlayStation 2", altName: "Sony - PlayStation 2", slug: "ps2"),
      Console(
          name: "PlayStation 3", altName: "Sony - PlayStation 3", slug: "ps3"),
      Console(
          name: "PlayStation Portable",
          altName: "Sony - PlayStation Portable",
          slug: "psp"),
      Console(
          name: "PlayStation Vita",
          altName: "Sony - PlayStation Vita",
          slug: "psvita"),
      // =========================
      // Sega
      // =========================
      Console(
          name: "Master System", altName: "Sega - Master System", slug: "sms"),
      Console(
          name: "Mega Drive / Genesis",
          altName: "Sega - Mega Drive - Genesis",
          slug: "genesis"),
      Console(name: "Sega CD", altName: "Sega - Sega CD", slug: "segacd"),
      Console(name: "Sega 32X", altName: "Sega - 32X", slug: "sega32x"),
      Console(name: "Sega Saturn", altName: "Sega - Saturn", slug: "saturn"),
      Console(
          name: "Dreamcast", altName: "Sega - Dreamcast", slug: "dreamcast"),
      Console(name: "Game Gear", altName: "Sega - Game Gear", slug: "gamegear"),

      // =========================
      // Atari
      // =========================
      Console(name: "Atari 2600", altName: "Atari - 2600", slug: "atari2600"),
      Console(name: "Atari 5200", altName: "Atari - 5200", slug: "atari5200"),
      Console(name: "Atari 7800", altName: "Atari - 7800", slug: "atari7800"),
      Console(name: "Atari Jaguar", altName: "Atari - Jaguar", slug: "jaguar"),
      Console(name: "Atari Lynx", altName: "Atari - Lynx", slug: "lynx"),
      // =========================
      // NEC / PC Engine
      // =========================
      Console(name: "PC Engine", altName: "NEC - PC Engine", slug: "pce"),
      Console(
          name: "PC Engine CD", altName: "NEC - PC Engine CD", slug: "pcecd"),
      Console(
          name: "SuperGrafx", altName: "NEC - SuperGrafx", slug: "supergrafx"),
      // =========================
      // SNK
      // =========================
      Console(name: "Neo Geo", altName: "SNK - Neo Geo", slug: "neogeo"),
      Console(
          name: "Neo Geo Pocket", altName: "SNK - Neo Geo Pocket", slug: "ngp"),
      Console(
          name: "Neo Geo Pocket Color",
          altName: "SNK - Neo Geo Pocket Color",
          slug: "ngpc"),
      // =========================
      // Commodore
      // =========================
      Console(name: "Commodore 64", altName: "Commodore - 64", slug: "c64"),
      Console(
          name: "Commodore Amiga", altName: "Commodore - Amiga", slug: "amiga"),

      // =========================
      // Others
      // =========================
      Console(
          name: "WonderSwan",
          altName: "Bandai - WonderSwan",
          slug: "wonderswan"),
      Console(
          name: "WonderSwan Color",
          altName: "Bandai - WonderSwan Color",
          slug: "wonderswancolor"),
      Console(name: "Vectrex", altName: "GCE - Vectrex", slug: "vectrex"),
      Console(
          name: "Odyssey²", altName: "Magnavox - Odyssey2", slug: "odyssey2"),
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
