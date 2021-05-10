import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:test_app/models/console.dart';
import 'package:test_app/models/rom_download.dart';
import 'package:test_app/providers/download_provider.dart';
import 'package:test_app/ui/pages/console_roms/console_roms_page.dart';
import 'package:test_app/ui/widgets/console_tile.dart';
import 'package:test_app/utils/assets_helper.dart';
import 'package:test_app/utils/consoles_helper.dart';

class DownloadedRomsConsoles extends StatelessWidget {
  List<RomDownload> downloadedRoms = [];
  Map<Console, int> _consolesWithDownloads = {};
  DownloadedRomsConsoles(List<RomDownload> roms) {
    this.downloadedRoms = roms;
    var _consoles = ConsolesHelper.getConsoles();
    for (var console in _consoles) {
      var count = getConsoleRoms(console).length;
      if (count > 0) {
        _consolesWithDownloads[console] = count;
      }
    }
  }
  List<RomDownload> getConsoleRoms(Console console) {
    return downloadedRoms
        .where((element) =>
            ConsolesHelper.getConsoleFromName(element.console).slug ==
            console.slug)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        // Generate 100 widgets that display their index in the List.
        children: List.generate(_consolesWithDownloads.length, (index) {
          var consoleDownload = _consolesWithDownloads.entries.toList()[index];
          var _console = consoleDownload.key;
          var _downloadCount = consoleDownload.value;

          return InkWell(
            onTap: () {
              var romInfos =
                  getConsoleRoms(_console).map((e) => e.toRomInfo()).toList();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ConsoleRomsPage(_console,
                      infos: romInfos.reversed.toList())));
            },
            child: FadeInUp(
              delay: Duration(milliseconds: 50 * index),
              child: ConsoleTile(
                _console,
                romsCount: _downloadCount,
              ),
            ),
          );
        }),
      ),
    );
  }
}
