import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/models/download_info.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/providers/download_provider.dart';
import 'package:neonrom3r/ui/widgets/download_spinner.dart';
import 'package:neonrom3r/utils/downloads_helper.dart';

class DownloadIndicator extends StatelessWidget {
  RomInfo rom;
  DownloadIndicator(this.rom);
  @override
  Widget build(BuildContext context) {
    var _provider = DownloadProvider.of(context);
    var _isDownloading = _provider.isRomDownloading(rom);
    var _isReadyToPlay = _provider.isRomReadyToPlay(rom);
    if (_isDownloading) {
      var _downloadInfo = _provider.getDownloadInfo(rom)!;
      return DownloadSpinner(_downloadInfo.downloadPercent!.toDouble());
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
