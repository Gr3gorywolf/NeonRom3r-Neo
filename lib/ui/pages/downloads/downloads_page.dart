import 'package:flutter/material.dart';
import 'package:test_app/models/rom_download.dart';
import 'package:test_app/models/rom_item.dart';
import 'package:test_app/ui/widgets/no_downloads_placeholder.dart';
import 'package:test_app/ui/pages/roms/roms_page.dart';
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
      _downloadedRoms = DownloadsHelper().getDownloadedRoms();
    });
  }

  bool hasDownloads() {
    return this._downloadedRoms.length > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Downloaded roms"),
      ),
      body:  (hasDownloads()
                ? NoDownloadsPlaceholder()
                : RomList(
                    isLoading: false, roms: [])),
    );
  }
}

