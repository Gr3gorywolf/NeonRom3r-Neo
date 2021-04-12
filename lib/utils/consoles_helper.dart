import 'package:test_app/models/console.dart';
import 'package:test_app/models/emulator.dart';

class ConsolesHelper {
  List<Console> getConsoles() {
    return [
      new Console(name: "Gameboy", slug: "GB"),
      new Console(name: "Gameboy Color", slug: "GBC"),
      new Console(name: "Gameboy Advance", slug: "GBA"),
      new Console(name: "Nintendo", slug: "NES"),
      new Console(name: "Super Nintendo", slug: "SNES"),
      new Console(name: "Nintendo 64", slug: "N64"),
      new Console(name: "Playstation", slug: "PSX"),
      new Console(name: "Sega Genesis", slug: "Genesis"),
      new Console(name: "Dreamcast", slug: "Dreamcast"),
      new Console(name: "Nintendo DS", slug: "NDS")
    ];
  }
}
