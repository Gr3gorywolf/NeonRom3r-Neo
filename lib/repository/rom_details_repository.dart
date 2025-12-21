import 'dart:convert';

import 'package:neonrom3r/models/hltb.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/models/tgdb.dart';
import 'package:neonrom3r/services/scrapers/hltb_scraper.dart';
import 'package:neonrom3r/services/scrapers/tgdb_scraper.dart';
import 'package:neonrom3r/services/cache_service.dart';
import 'package:neonrom3r/services/files_system_service.dart';
import 'package:neonrom3r/utils/cached_fetch.dart';

class RomDetailsRepository {
  Future<HltbEntry?> fetchHltbData(RomInfo rom) async {
    return await CachedFetch.object<HltbEntry>(
      key: "hltb_${rom.slug}",
      fetcher: () async {
        var scraper = HltbScraper();
        var results = await scraper.search(rom.name);
        if (results.isEmpty) {
          return null;
        }
        var result = results.first;
        var detail = await scraper.detail(result.id);
        return detail;
      },
      fromJson: (json) => HltbEntry.fromJson(json),
      ttl: Duration(days: 1),
    );
  }

  Future<TgdbGameDetail?> fetchTgdbData(RomInfo rom) async {
    return await CachedFetch.object<TgdbGameDetail>(
      key: "tgdb_${rom.slug}",
      fetcher: () async {
        var scraper = TheGamesDbScraper();
        var results = await scraper.search(rom.name, rom.console);
        if (results.isEmpty) {
          return null;
        }
        var result = results.first;
        var detail = await scraper.detail(result.id);
        return detail;
      },
      fromJson: (json) => TgdbGameDetail.fromJson(json),
      ttl: Duration(days: 1),
    );
  }
}
