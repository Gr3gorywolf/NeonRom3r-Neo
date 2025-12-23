import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:neonrom3r/constants/settings_constants.dart';
import 'package:neonrom3r/database/app_database.dart';
import 'package:neonrom3r/database/daos/library_dao.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/models/rom_library_item.dart';
import 'package:neonrom3r/services/download_service.dart';
import 'package:neonrom3r/services/settings_service.dart';
import 'package:neonrom3r/ui/widgets/rom_list_item.dart';
import 'package:neonrom3r/ui/widgets/view_mode_toggle.dart';
import 'package:provider/provider.dart';

class LibraryProvider extends ChangeNotifier {
  static LibraryProvider of(BuildContext ctx) {
    return Provider.of<LibraryProvider>(ctx);
  }

  Map<String, RomLibraryItem> _libraryItems = {};
  Set<String> _runningGames = {};
  List<RomLibraryItem> get libraryItems => _libraryItems.values.toList();

  init() async {
    if (db == null) {
      return;
    }
    var library = await LibraryDao(db!).getAll();
    for (var item in library) {
      _libraryItems[item.rom.slug] = item;
    }
  }

  List<RomLibraryItem> getDownloads() {
    return _libraryItems.values
        .where((item) => item.downloadedAt != null)
        .toList();
  }

  List<RomLibraryItem> getBySlugs(List<String> slugs) {
    List<RomLibraryItem> items = [];
    for (var slug in slugs) {
      var item = _libraryItems[slug];
      if (item != null) {
        items.add(item);
      }
    }
    return items;
  }

  bool isRomReadyToPlay(String romSlug) {
    var item = _libraryItems[romSlug];
    if (item == null) {
      return false;
    }
    return item.filePath != null;
  }

  bool isGameRunning(String slug) {
    return _runningGames.contains(slug);
  }

  setGameRunning(String slug, bool running) {
    if (running) {
      _runningGames.add(slug);
    } else {
      _runningGames.remove(slug);
    }
    notifyListeners();
  }

  RomLibraryItem? getLibraryItem(String romSlug) {
    return _libraryItems[romSlug];
  }

  addRomToLibrary(RomInfo rom) async {
    addLibraryItem(RomLibraryItem(rom: rom, addedAt: DateTime.now()));
  }

  addLibraryItem(RomLibraryItem item) async {
    if (db == null) {
      return;
    }
    await LibraryDao(db!).insert(item);
    _libraryItems[item.rom.slug] = item;
    notifyListeners();
    if (await SettingsService().get<bool>(SettingsKeys.ENABLE_IMAGE_CACHING)) {
      DownloadService().catchRomPortrait(item.rom);
    }
  }

  removeLibraryItem(String romSlug) async {
    if (db == null) {
      return;
    }
    await LibraryDao(db!).delete(romSlug);
    _libraryItems.remove(romSlug);
    notifyListeners();
  }

  Future<void> updateLibraryItem(RomLibraryItem item) async {
    if (db == null) {
      return;
    }
    await LibraryDao(db!).update(item);
    _libraryItems[item.rom.slug] = item;
    notifyListeners();
  }
}
