import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:test_app/models/download_info.dart';
import 'package:test_app/models/rom_info.dart';
import 'package:test_app/providers/download_provider.dart';
import 'package:test_app/ui/widgets/download_spinner.dart';
import 'package:test_app/utils/downloads_helper.dart';

class DownloadIndicator extends StatelessWidget {
  RomInfo rom;
  DownloadIndicator(this.rom);
  @override
  Widget build(BuildContext context) {
    var _provider = DownloadProvider.of(context);
    var _isDownloading = _provider.isRomDownloading(rom);
    var _isReadyToPlay = _provider.isRomReadyToPlay(rom);
    if (_isDownloading) {
      var _downloadInfo = _provider.getDownloadInfo(rom);
      return DownloadSpinner(_downloadInfo.downloadPercent.toDouble());
    } else if (_isReadyToPlay) {
      return FadeIn(
        duration: Duration(milliseconds: 1200),
              child: Icon(
          Icons.download_done_sharp,
          color: Colors.green,
          size: 30,
        ),
      );
    } else {
      return SizedBox();
    }
  }
}
