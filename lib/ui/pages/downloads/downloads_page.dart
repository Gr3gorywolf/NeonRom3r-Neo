import 'dart:io';

import 'package:flutter/material.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:test_app/models/rom_download.dart';
import 'package:test_app/providers/download_provider.dart';
import 'package:test_app/ui/pages/downloads/widgets/downloaded_roms_consoles.dart';
import 'package:test_app/ui/widgets/console_list.dart';
import 'package:test_app/ui/widgets/no_downloads_placeholder.dart';
import 'package:test_app/ui/pages/roms/roms_page.dart';
import 'package:test_app/ui/widgets/rom_list.dart';
import 'package:test_app/utils/downloads_helper.dart';

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
    _downloadedRoms = DownloadProvider.of(context)
        .downloadsRegistry
        .where((element) => File(element.filePath).existsSync())
        .toList();
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
                      child: Text('All'),
                      padding: EdgeInsets.only(left: 6, right: 6),
                    ),
                    2: Padding(
                      child: Text('History'),
                      padding: EdgeInsets.only(left: 6, right: 6),
                    )
                  },
                  selectionIndex: _currentSelection,
                  borderColor: Colors.green,
                  selectedColor: Colors.green,
                  unselectedColor: Colors.grey[900],
                  borderRadius: 8.0,
                  horizontalPadding: EdgeInsets.only(top: 15, bottom: 5),
                  onSegmentChosen: (index) {
                    setState(() {
                      _currentSelection = index;
                    });
                  },
                ),
                Expanded(
                  child: _currentSelection == 0
                      ? DownloadedRomsConsoles(_downloadedRoms)
                      : RomList(
                          isLoading: false,
                          showConsole: true,
                          roms: _downloadedRoms
                              .map((e) => e.toRomInfo())
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
