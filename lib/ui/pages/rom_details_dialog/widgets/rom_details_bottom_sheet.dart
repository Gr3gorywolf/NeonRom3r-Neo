import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:neonrom3r/models/download_source_rom.dart';
import 'package:neonrom3r/ui/widgets/rom_download_sources_dialog/rom_download_sources_dialog.dart';
import 'package:neonrom3r/ui/widgets/rom_thumbnail.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/providers/download_provider.dart';
import 'package:neonrom3r/ui/pages/rom_details_dialog/widgets/rom_details_action_button.dart';
import 'package:neonrom3r/ui/widgets/download_spinner.dart';
import 'package:neonrom3r/utils/alerts_helpers.dart';
import 'package:neonrom3r/utils/downloads_helper.dart';
import 'package:neonrom3r/utils/roms_helper.dart';
import 'package:toast/toast.dart';

class RomDetailsBottomSheet extends StatefulWidget {
  final RomInfo rom;
  RomDetailsBottomSheet(this.rom);
  @override
  _RomDetailsBottomSheetState createState() => _RomDetailsBottomSheetState();
}

class _RomDetailsBottomSheetState extends State<RomDetailsBottomSheet> {
  double _iconsSize = 30;

  DownloadProvider get _downloadProvider {
    return Provider.of<DownloadProvider>(context, listen: false);
  }

  shareFile() {
    var downloadedRom = _downloadProvider.getDownloadedRomInfo(widget.rom)!;
    Share.shareFiles([downloadedRom.filePath!],
        text: "${widget.rom.name}\n shared and downloaded from NeonRom3r");
  }

  shareLink() {}

  handleShare() {
    bool isRomDownloaded = _downloadProvider.isRomReadyToPlay(widget.rom);
    AlertsHelpers.showAlert(
        context, "Rom share", "How do you want to share your rom?",
        cancelable: true,
        additionalAction: isRomDownloaded ? buildShareFileAction() : null,
        acceptTitle: "Download link",
        callback: shareLink);
  }

  buildShareFileAction() {
    return TextButton(onPressed: shareFile, child: Text("Rom file"));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[900]!,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 2,
              color: Colors.green,
              margin: EdgeInsets.only(bottom: 10),
            ),
            //Rom details row
            Row(
              children: [
                RomThumbnail(
                  widget.rom,
                  height: 94,
                  width: 94,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.rom.name!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        SizedBox(height: 5),
                      ],
                      mainAxisSize: MainAxisSize.min),
                )
              ],
            ),

            //Rom actions row
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RomDetailsActionButton(widget.rom),
                SizedBox(
                  width: 12,
                ),
                IconButton(
                  onPressed: handleShare,
                  icon: Icon(
                    Icons.share,
                    size: _iconsSize,
                  ),
                  color: Colors.green,
                ),
                /*FadeInLeft(
                  delay: Duration(milliseconds: 200),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_drop_down_circle_outlined,
                      size: _iconsSize,
                    ),
                    color: Colors.green,
                  ),
                )*/
              ],
            )
          ],
        ),
      ),
    );
  }
}
