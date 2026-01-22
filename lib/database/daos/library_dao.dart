import 'package:yamata_launcher/database/db_stores.dart';
import 'package:yamata_launcher/models/rom_library_item.dart';
import 'package:sembast/sembast.dart';

class LibraryDao {
  final Database db;
  LibraryDao(this.db);

  Future<RomLibraryItem?> get(String slug) async {
    final records = await romLibraryDbStore.record(slug).get(db);
    if (records == null) {
      return null;
    }
    return RomLibraryItem.fromJson(records);
  }

  Future<List<RomLibraryItem>> getAll() async {
    final records = await romLibraryDbStore.find(db);
    return records.map((e) => RomLibraryItem.fromJson(e.value)).toList();
  }

  Future<List<RomLibraryItem>> getImported() async {
    final records = await romLibraryDbStore.find(
      db,
      finder: Finder(
        filter: Filter.equals('isImported', true),
      ),
    );
    return records.map((e) => RomLibraryItem.fromJson(e.value)).toList();
  }

  Future<String?> insert(RomLibraryItem item) async {
    return await romLibraryDbStore.record(item.rom.slug).add(db, item.toJson());
  }

  Future<Map<String, Object?>?> update(RomLibraryItem item) async {
    return await romLibraryDbStore
        .record(item.rom.slug)
        .update(db, item.toJson());
  }

  Future<String?> delete(String romSlug) async {
    final records = await romLibraryDbStore.record(romSlug).delete(db);
    return records;
  }
}
