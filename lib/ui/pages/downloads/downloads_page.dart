import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test_app/models/rom_download.dart';
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _downloadedRoms = DownloadsHelper()
          .getDownloadedRoms()
          .where((element) => File(element.filePath).existsSync())
          .toList();
    });
  }

  bool get hasDownloads {
    return this._downloadedRoms.length > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Downloads"),
      ),
      body: (hasDownloads
          ? RomList(
              isLoading: false,
              roms: _downloadedRoms
                  .map((e) => e.toRomInfo())
                  .toList()
                  .reversed
                  .toList())
          : NoDownloadsPlaceholder()),
    );
  }
}
