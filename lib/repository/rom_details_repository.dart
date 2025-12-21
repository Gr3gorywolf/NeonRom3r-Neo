import 'dart:convert';

import 'package:neonrom3r/models/hltb.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/models/tgdb.dart';
import 'package:neonrom3r/scrapers/hltb_scraper.dart';
import 'package:neonrom3r/scrapers/tgdb_scraper.dart';
import 'package:neonrom3r/utils/cache_helper.dart';
import 'package:neonrom3r/utils/files_system_helper.dart';

class RomDetailsRepository {
  Future<HltbEntry?> fetchHltbData(RomInfo rom) async {
    var cacheKey = "details-caches/hltb_${rom.slug}";
    var foundCache = await CacheHelper.retrieveCacheFile(
      cacheKey,
    );
    if (foundCache != null) {
      return HltbEntry.fromJson(json.decode(foundCache));
    }
    try {
      var scraper = HltbScraper();
      var results = await scraper.search(rom.name);
      if (results.isEmpty) {
        return null;
      }
      var result = results.first;
      var detail = await scraper.detail(result.id);
      await CacheHelper.writeCacheFile(
        cacheKey,
        json.encode(detail.toJson()),
        ttl: Duration(days: 7),
      );
      return detail;
    } catch (e) {
      print("Error fetching HLTB data: $e");
      return null;
    }
  }

  Future<TgdbGameDetail?> fetchTgdbData(RomInfo rom) async {
    var cacheKey = "details-caches/tgdb_${rom.slug}";
    var foundCache = await CacheHelper.retrieveCacheFile(
      cacheKey,
    );
    if (foundCache != null) {
      return TgdbGameDetail.fromJson(json.decode(foundCache));
    }
    try {
      var scraper = TheGamesDbScraper();
      var results = await scraper.search(rom.name, rom.console);
      if (results.isEmpty) {
        return null;
      }
      var result = results.first;
      var detail = await scraper.detail(result.id);
      await CacheHelper.writeCacheFile(
        cacheKey,
        json.encode(detail.toJson()),
        ttl: Duration(days: 7),
      );
      return detail;
    } catch (e) {
      print("Error fetching TGDB data: $e");
      return null;
    }
  }
}
