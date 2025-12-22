import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:neonrom3r/models/download_info.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/models/rom_library_item.dart';
import 'package:neonrom3r/providers/download_provider.dart';
import 'package:neonrom3r/providers/download_sources_provider.dart';
import 'package:neonrom3r/providers/library_provider.dart';
import 'package:neonrom3r/ui/widgets/download_spinner.dart';
import 'package:neonrom3r/ui/widgets/rom_download_sources_dialog/rom_download_sources_dialog.dart';
import 'package:neonrom3r/services/download_service.dart';
import 'package:neonrom3r/services/rom_service.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../models/download_source_rom.dart';
import '../../services/alerts_service.dart';

enum RomActionButtonSize { small, large, medium }

class RomActionButton extends StatelessWidget {
  RomInfo rom;
  RomActionButtonSize size;
  RomActionButton(this.rom, {this.size = RomActionButtonSize.medium});
  @override
  Widget build(BuildContext context) {
    var _provider = DownloadProvider.of(context);
    var libraryProvider = Provider.of<LibraryProvider>(context);

    var libraryItem = libraryProvider.getLibraryItem(rom.slug);
    var _download_sources_provider =
        Provider.of<DownloadSourcesProvider>(context);
    var _isDownloading = _provider.isRomDownloading(rom);
    var _isReadyToPlay = libraryProvider.isRomReadyToPlay(rom.slug);
    var _has_download_sources =
        _download_sources_provider.getRomSources(rom.slug).isNotEmpty;

    double horizontalPadding;
    double verticalPadding;
    double iconSize;
    double fontSize;
    double spacing;

    var icon = Icons.cloud_off_rounded;
    var text = "No downloads";

    handleCancelDownload() {
      AlertsService.showAlert(
          context, "Warning", "You are sure you want to cancel this download?",
          acceptTitle: "Yes", callback: () {
        Provider.of<DownloadProvider>(context, listen: false)
            .abortDownload(_provider.getDownloadInfo(rom)!);
        AlertsService.showSnackbar(context, "Download cancelled");
      }, cancelable: true);
    }

    handleShowDownload() async {
      final romSource = await showDialog<DownloadSourceRom>(
        context: context,
        builder: (_) => RomDownloadSourcesDialog(
          rom: rom,
        ),
      );
      if (romSource == null) {
        return;
      }
      await libraryProvider.addRomToLibrary(rom);
      DownloadService().downloadRom(context, rom, romSource);
      AlertsService.showSnackbar(context, "Download started", duration: 3);
    }

    switch (size) {
      case RomActionButtonSize.small:
        horizontalPadding = 10;
        verticalPadding = 10;
        iconSize = 16;
        fontSize = 11;
        spacing = 2;
        break;
      case RomActionButtonSize.large:
        horizontalPadding = 20;
        verticalPadding = 20;
        iconSize = 28;
        fontSize = 16;
        spacing = 5;
        break;
      case RomActionButtonSize.medium:
      default:
        horizontalPadding = 15;
        verticalPadding = 16;
        iconSize = 24;
        fontSize = 13;
        spacing = 3;
        break;
    }
    if (_has_download_sources) {
      icon = Icons.cloud_download;
      text = "Download";
    }
    if (_isDownloading) {
      icon = Icons.stop;
      text = "Cancel";
    } else if (_isReadyToPlay) {
      icon = Icons.play_arrow_outlined;
      text = "Play";
    }

    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: verticalPadding)),
        onPressed: _has_download_sources || _isReadyToPlay || _isDownloading
            ? () => {
                  if (_isDownloading)
                    {handleCancelDownload()}
                  else if (_isReadyToPlay && libraryItem != null)
                    {
                      RomService.openDownloadedRom(libraryItem),
                      AlertsService.showSnackbar(context, "Rom launched")
                    }
                  else
                    {
                      handleShowDownload(),
                    }
                }
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize),
            SizedBox(
              width: spacing,
            ),
            Text(text,
                style:
                    TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600)),
          ],
        ));
  }
}
