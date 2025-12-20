import 'package:neonrom3r/models/hltb.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/models/tgdb.dart';
import 'package:neonrom3r/scrapers/hltb_scraper.dart';
import 'package:neonrom3r/scrapers/tgdb_scraper.dart';

class RomDetailsRepository {
  Future<HltbEntry?> fetchHltbData(String romName) async {
    try {
      var scraper = HltbScraper();
      var results = await scraper.search(romName);
      if (results.isEmpty) {
        return null;
      }
      var result = results.first;
      var detail = await scraper.detail(result.id);
      return detail;
    } catch (e) {
      print("Error fetching HLTB data: $e");
      return null;
    }
  }

  Future<TgdbGameDetail?> fetchTgdbData(RomInfo rom) async {
    try {
      var scraper = TheGamesDbScraper();
      var results = await scraper.search(rom.name, rom.console);
      if (results.isEmpty) {
        return null;
      }
      var result = results.first;
      print(result);
      var detail = await scraper.detail(result.id);
      return detail;
    } catch (e) {
      print("Error fetching TGDB data: $e");
      return null;
    }
  }
}
