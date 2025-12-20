import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:neonrom3r/models/download_source_rom.dart';
import 'package:neonrom3r/models/hltb.dart';
import 'package:neonrom3r/models/tgdb.dart';
import 'package:neonrom3r/repository/rom_details_repository.dart';
import 'package:neonrom3r/ui/widgets/Images_carousel.dart';
import 'package:neonrom3r/ui/widgets/rom_action_button.dart';
import 'package:neonrom3r/ui/widgets/rom_download_sources_dialog/rom_download_sources_dialog.dart';
import 'package:neonrom3r/ui/widgets/rom_thumbnail.dart';
import 'package:neonrom3r/utils/consoles_helper.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/providers/download_provider.dart';
import 'package:neonrom3r/ui/pages/rom_details_dialog/widgets/rom_details_action_button.dart';
import 'package:neonrom3r/ui/widgets/download_spinner.dart';
import 'package:neonrom3r/utils/alerts_helpers.dart';
import 'package:neonrom3r/utils/downloads_helper.dart';
import 'package:neonrom3r/utils/roms_helper.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toast/toast.dart';

class RomDetailsBottomSheet extends StatefulWidget {
  final RomInfo rom;
  RomDetailsBottomSheet(this.rom);
  @override
  _RomDetailsBottomSheetState createState() => _RomDetailsBottomSheetState();
}

class _RomDetailsBottomSheetState extends State<RomDetailsBottomSheet> {
  var isFetchingHltbDetails = false;
  var isFetchingTgdbDetails = false;
  HltbEntry? hltbInfo = null;
  TgdbGameDetail? tgdbInfo = null;
  void fetchHltbInfo() async {
    setState(() {
      isFetchingHltbDetails = true;
    });

    var data = await RomDetailsRepository().fetchHltbData(widget.rom.name);

    setState(() {
      hltbInfo = data;
      isFetchingHltbDetails = false;
    });
  }

  void fetchTgdbInfo() async {
    setState(() {
      isFetchingTgdbDetails = true;
    });
    var tgdbData = await RomDetailsRepository().fetchTgdbData(widget.rom);
    setState(() {
      tgdbInfo = tgdbData;
      isFetchingTgdbDetails = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchHltbInfo();
    fetchTgdbInfo();
    super.initState();
  }

  String formatDuration(int? hours) {
    if (hours == null) {
      return "--";
    }
    return "${hours}h";
  }

  String get description {
    if (hltbInfo != null && hltbInfo!.description.isNotEmpty) {
      return hltbInfo!.description;
    }
    if (tgdbInfo != null && tgdbInfo!.description.isNotEmpty) {
      return tgdbInfo!.description;
    }
    return "No description available.";
  }

  @override
  Widget build(BuildContext context) {
    var thumbnail = RomThumbnail(widget.rom);
    var _provider = DownloadProvider.of(context);
    var _downloadInfo = _provider.getDownloadInfo(widget.rom);
    var _isRomDownloaded = _provider.getDownloadedRomInfo(widget.rom);
    var console = ConsolesHelper.getConsoleFromName(widget.rom.console);
    var lastPlayed =
        _isRomDownloaded != null ? "Last played: " : "Not installed";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 170,
              height: 228,
              child: ClipRRect(
                  child: thumbnail, borderRadius: BorderRadius.circular(6)),
            ),
            SizedBox(width: 20),
            Container(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Badge(
                    label: Text(
                      ConsolesHelper.getConsoleFromName(widget.rom.console)
                              ?.name ??
                          "Unknown Console",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Text(
                    widget.rom.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                    maxLines: 2,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Opacity(
                    opacity: 0.7,
                    child: Text(
                      widget.rom.releaseDate?.isEmpty ?? true
                          ? "1994"
                          : widget.rom.releaseDate!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Skeletonizer(
                    enabled: isFetchingHltbDetails,
                    child: Opacity(
                      opacity: 0.7,
                      child: Text(
                        "Main: ${formatDuration(hltbInfo?.gameplayMain)} | Sides: ${formatDuration(hltbInfo?.gameplayMainExtra)} | Completion: ${formatDuration(hltbInfo?.gameplayCompletionist)}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Skeletonizer(
                    enabled: isFetchingHltbDetails,
                    child: Text(
                      description,
                      maxLines: 5,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ...(_downloadInfo != null
            ? [
                SizedBox(
                  height: 20,
                ),
                LinearProgressIndicator(
                  backgroundColor: Colors.grey[800],
                  value: (_downloadInfo.downloadPercent ?? 0) / 100,
                ),
                SizedBox(
                  height: 3,
                ),
                Opacity(
                  opacity: 0.7,
                  child: Text(
                    _downloadInfo.downloadInfo ?? "",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ]
            : [SizedBox(height: 25)]),
        Row(
          children: [
            RomActionButton(
              widget.rom,
              size: RomActionButtonSize.medium,
            ),
            SizedBox(width: 2),
            IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
            SizedBox(width: 2),
            IconButton(onPressed: () {}, icon: Icon(Icons.star_border)),
            SizedBox(width: 10),
            Opacity(
              opacity: 0.7,
              child: Text(lastPlayed,
                  style: Theme.of(context).textTheme.labelSmall),
            )
          ],
        ),
        SizedBox(height: 10),
        Skeletonizer(
          enabled: isFetchingTgdbDetails,
          child: Text(
            "Screenshots",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(height: 10),
        Skeletonizer(
          enabled: isFetchingTgdbDetails,
          child: ImagesCarousel(
            images: [
              ...(isFetchingTgdbDetails
                  ? ["https://placehold.co/600x400.png"]
                  : []),
              ...(tgdbInfo?.screenshots ?? []),
              ...(tgdbInfo?.titleScreens ?? []),
            ],
            height: 300,
          ),
        ),
      ],
    );
  }
}
