import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:yamata_launcher/models/launchbox_rom_details.dart';

class LaunchboxScraper {
  Future<LaunchboxRomDetails?> detail(String url) async {
    final res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      return null;
    }

    final doc = html_parser.parse(res.body);

    // ---------- DESCRIPTION (Overview) ----------
    String? description;
    try {
      final overviewArticle =
          doc.querySelector('section.game-details-content article');
      if (overviewArticle != null) {
        final paragraphs =
            overviewArticle.querySelectorAll('p.text-body-lg.text-dark-100');
        final descText = paragraphs
            .map((p) => p.text.trim())
            .where((t) => t.isNotEmpty)
            .join('\n\n');
        if (descText.isNotEmpty) {
          description = descText;
        }
      }
    } catch (_) {
      description = null;
    }

    // ---------- Details ----------
    String? maxPlayers;
    bool? cooperative;
    String? esrb;

    try {
      final detailRows = doc.querySelectorAll('aside dl > div');
      for (final row in detailRows) {
        final dt = row.querySelector('dt');
        final dd = row.querySelector('dd');
        if (dt == null || dd == null) continue;

        final label = dt.text.trim();
        final value = dd.text.trim();

        switch (label) {
          case 'Max Players':
            maxPlayers = value;
            break;
          case 'Cooperative':
            cooperative = value.toLowerCase().startsWith('y')
                ? true
                : value.toLowerCase().startsWith('n')
                    ? false
                    : null;
            break;
          case 'ESRB':
            esrb = value;
            break;
          default:
            break;
        }
      }
    } catch (_) {}

    // ---------- GENRES ----------
    List<String>? genres;
    try {
      final overviewArticle =
          doc.querySelector('section.game-details-content article');
      if (overviewArticle != null) {
        final dts = overviewArticle.querySelectorAll('dl dt');
        Element? genreDt;
        for (final dt in dts) {
          if (dt.text.trim() == 'Genre') {
            genreDt = dt;
            break;
          }
        }

        if (genreDt != null) {
          final parentDiv = genreDt.parent;
          final dd = parentDiv?.querySelector('dd');
          if (dd != null) {
            final genreLinks = dd.querySelectorAll('a');
            genres = genreLinks
                .map((a) => a.text.trim())
                .where((t) => t.isNotEmpty)
                .toList();
          }
        }
      }
    } catch (_) {
      genres = null;
    }

    String? video;
    try {
      final overviewArticle =
          doc.querySelector('section.game-details-content article');
      if (overviewArticle != null) {
        final dts = overviewArticle.querySelectorAll('dl dt');
        Element? videoDt;
        for (final dt in dts) {
          if (dt.text.trim() == 'Video') {
            videoDt = dt;
            break;
          }
        }

        if (videoDt != null) {
          final parentDiv = videoDt.parent; // <div> con dt y dd
          final dd = parentDiv?.querySelector('dd');
          final a = dd?.querySelector('a');
          video = a?.attributes['href'];
        }
      }
    } catch (_) {
      video = null;
    }

    List<String>? screenshots;
    try {
      final imgNodes = doc.querySelectorAll('img');
      final urls = <String>{};

      for (final img in imgNodes) {
        final alt = img.attributes['alt'] ?? '';
        if (alt.contains('Screenshot')) {
          final src = img.attributes['src'] ?? '';
          if (src.isNotEmpty) {
            urls.add(src);
          }
        }
      }

      if (urls.isNotEmpty) {
        screenshots = urls.toList();
      }
    } catch (_) {
      screenshots = null;
    }

    return LaunchboxRomDetails(
      description: description,
      maxPlayers: maxPlayers,
      cooperative: cooperative,
      esrb: esrb,
      genres: genres,
      video: video,
      screenshots: screenshots,
    );
  }
}
