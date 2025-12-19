import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:neonrom3r/models/rom_download.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/providers/download_provider.dart';
import 'package:neonrom3r/ui/pages/downloads/widgets/downloaded_roms_consoles.dart';
import 'package:neonrom3r/ui/widgets/console_list.dart';
import 'package:neonrom3r/ui/widgets/no_downloads_placeholder.dart';
import 'package:neonrom3r/ui/pages/home/home_page.dart';
import 'package:neonrom3r/ui/widgets/rom_list.dart';
import 'package:neonrom3r/utils/downloads_helper.dart';

class DownloadsPage extends StatefulWidget {
  @override
  _DownloadsPageState createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  List<RomDownload> _downloadedRoms = [];
  int _currentSelection = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool get hasDownloads {
    return this._downloadedRoms.length > 0;
  }

  @override
  Widget build(BuildContext context) {
    var provider = DownloadProvider.of(context);
    _downloadedRoms = provider.downloadsRegistry.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text("Downloads"),
      ),
      body: (hasDownloads
          ? Column(
              children: [
                MaterialSegmentedControl(
                  children: {
                    0: Padding(
                      child: Text('History'),
                      padding: EdgeInsets.only(left: 6, right: 6),
                    ),
                    2: Padding(
                      child: Text('All'),
                      padding: EdgeInsets.only(left: 6, right: 6),
                    ),
                  },
                  selectionIndex: _currentSelection,
                  borderColor: Colors.green,
                  selectedColor: Colors.green,
                  unselectedColor: Colors.grey[900]!,
                  borderRadius: 8.0,
                  horizontalPadding: EdgeInsets.only(top: 15, bottom: 5),
                  onSegmentChosen: (dynamic index) {
                    setState(() {
                      _currentSelection = index;
                    });
                  },
                ),
                Expanded(
                  child: _currentSelection == 2
                      ? DownloadedRomsConsoles(
                          _downloadedRoms as List<RomDownload>)
                      : RomList(
                          isLoading: false,
                          showConsole: true,
                          roms: _downloadedRoms
                              .map(((e) => e.toRomInfo()))
                              .toList()
                              .reversed
                              .take(50)
                              .toList()),
                ),
              ],
            )
          : NoDownloadsPlaceholder()),
    );
  }
}
