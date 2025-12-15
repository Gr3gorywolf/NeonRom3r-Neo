import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:neonrom3r/models/download_source_rom.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/providers/download_provider.dart';
import 'package:neonrom3r/ui/widgets/download_spinner.dart';
import 'package:neonrom3r/ui/widgets/rom_download_sources_dialog/rom_download_sources_dialog.dart';
import 'package:neonrom3r/utils/alerts_helpers.dart';
import 'package:neonrom3r/utils/downloads_helper.dart';
import 'package:neonrom3r/utils/roms_helper.dart';
import 'package:toast/toast.dart';

class RomDetailsActionButton extends StatefulWidget {
  RomInfo rom;
  RomDetailsActionButton(this.rom);

  @override
  _RomDetailsActionButtonState createState() => _RomDetailsActionButtonState();
}

class _RomDetailsActionButtonState extends State<RomDetailsActionButton> {
  double _iconsSize = 30;

  handleShowDownload() async {
    final romSource = await showDialog<DownloadSourceRom>(
      context: context,
      builder: (_) => RomDownloadSourcesDialog(
        rom: widget.rom,
      ),
    );
    if (romSource == null) {
      return;
    }
    DownloadsHelper().downloadRom(this.widget.rom, romSource);
    Toast.show("Download started...", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  handlePlay() async {
    var downloaded = DownloadsHelper().getDownloadedRoms();
    var rom = downloaded.firstWhere(
        (element) => element.downloadLink == widget.rom.downloadLink);
    Toast.show("Launching rom...", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    await RomsHelper.openDownloadedRom(rom);
    Toast.show("Rom launched", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  handleCancelDownload(String downloadId) {
    AlertsHelpers.showAlert(
        context, "Warning", "You are sure you want to cancel this download?",
        acceptTitle: "Yes", callback: () {
      FlutterDownloader.cancel(taskId: downloadId);
    }, cancelable: true);
  }

  @override
  Widget build(BuildContext context) {
    var _provider = DownloadProvider.of(context);
    var _isDownloading = _provider.isRomDownloading(widget.rom);
    var _isReadyToPlay = _provider.isRomReadyToPlay(widget.rom);
    if (_isDownloading) {
      var _downloadInfo = _provider.getDownloadInfo(widget.rom);
      var _percent = _downloadInfo.downloadPercent.toDouble();

      return InkWell(
        onTap: () => handleCancelDownload(_downloadInfo.downloadId),
        child: Container(
          width: 36,
          height: 36,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: 6,
                left: 5,
                child: Icon(Icons.stop, color: Colors.green),
              ),
              DownloadSpinner(
                _percent,
                showPercent: false,
              ),
            ],
          ),
        ),
      );
    }
    if (_isReadyToPlay) {
      return IconButton(
        onPressed: handlePlay,
        icon: Icon(
          Icons.play_arrow_sharp,
          size: _iconsSize,
        ),
        color: Colors.green,
      );
    } else {
      return IconButton(
        onPressed: handleShowDownload,
        icon: Icon(
          Icons.download_rounded,
          size: _iconsSize,
        ),
        color: Colors.green,
      );
    }
  }
}
