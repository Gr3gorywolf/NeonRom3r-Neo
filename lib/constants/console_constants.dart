import 'package:yamata_launcher/models/console.dart';

class ConsoleConstants {
  static List<Console> defaultConsoles = [
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
    Console(
        name: "Nintendo DS", altName: "Nintendo - Nintendo DS", slug: "nds"),
    Console(
        name: "Nintendo 3DS", altName: "Nintendo - Nintendo 3DS", slug: "3ds"),
    Console(
        name: "Virtual Boy",
        altName: "Nintendo - Virtual Boy",
        slug: "virtualboy"),

    // =========================
    // Sony
    // =========================
    Console(name: "PlayStation", altName: "Sony - PlayStation", slug: "psx"),
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
        slug: "vita"),
    // =========================
    // Sega
    // =========================
    Console(
        name: "Mega Drive / Genesis",
        altName: "Sega - Mega Drive - Genesis",
        slug: "genesis"),
    Console(name: "Sega 32X", altName: "Sega - 32X", slug: "sega32x"),
    Console(name: "Sega Saturn", altName: "Sega - Saturn", slug: "saturn"),
    Console(name: "Dreamcast", altName: "Sega - Dreamcast", slug: "dreamcast"),
    Console(name: "Game Gear", altName: "Sega - Game Gear", slug: "gamegear"),

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
    Console(name: "WonderSwan", altName: "Bandai - WonderSwan", slug: "ws"),
    Console(
        name: "WonderSwan Color",
        altName: "Bandai - WonderSwan Color",
        slug: "wsc"),
    Console(name: "Vectrex", altName: "GCE - Vectrex", slug: "vectrex"),
  ];
}
